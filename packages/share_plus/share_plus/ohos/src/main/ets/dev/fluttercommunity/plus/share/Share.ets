/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import common from '@ohos.app.ability.common';
import UIAbility from '@ohos.app.ability.UIAbility';
import fs from '@ohos.file.fs';
import { fileUri } from '@kit.CoreFileKit';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import systemShare from '@hms.collaboration.systemShare';
import uniformTypeDescriptor from '@ohos.data.uniformTypeDescriptor';

const TAG = 'Share';

export default class Share {
  public context: common.Context | null = null;
  public ability?: UIAbility | null = null;
  // The active share sheet controller and its dismiss listener, kept as fields
  // so the listener can be unregistered with the same function reference.
  private shareController: systemShare.ShareController | null = null;
  private dismissCallback: (() => void) | null = null;
  // Concurrency guard: a second share while one is copying files into the
  // cache folder would race on that folder (clear/delete of in-flight files).
  private isSharing: boolean = false;

  constructor(context: common.Context, ability?: UIAbility) {
    this.context = context;
  }

  public setAbility(ability: UIAbility | null): void {
    this.ability = ability;
  }

  /// Release resources held by this instance: unregisters the dismiss
  /// listener (so no dangling callback survives) and drops the ability
  /// reference. Called from onDetachedFromAbility/onDetachedFromEngine.
  public dispose(): void {
    this.unregisterDismissListener();
    this.ability = null;
  }

  public async share(
    text: string,
    subject: string | null,
    title: string | null,
    withResult: boolean,
    result: MethodResult): Promise<void> {
    Log.i(TAG, "share");
    Log.i(TAG, "share with title: " + title);
    if (this.isSharing || this.shareController != null) {
      Log.e(TAG, 'a share operation is already in progress');
      if (withResult) {
        result.error('share_error', 'a share operation is already in progress', null);
      }
      return;
    }
    this.isSharing = true;
    try {
      let record: systemShare.SharedRecord = {
        utd: uniformTypeDescriptor.getUniformDataTypeByMIMEType('text/plain'),
        content: text,
        title: title || subject || '',
      }
      if(title != null && title.length !=0) {
        record.description = text;
      }
      let data = new systemShare.SharedData(record);
      this.startShare(data, withResult, result);
    } catch (err) {
      Log.e(TAG, 'share err:' + JSON.stringify(err));
      // Only the *WithResult variants own `result` (the handler replies
      // immediately for the non-result variants). Guard to avoid double
      // replies while still unblocking the Dart Future on failure.
      if (withResult) {
        result.error('share_error', 'share failed: ' + JSON.stringify(err), null);
      }
    } finally {
      this.isSharing = false;
    }
  }

  public async shareFiles(paths: string[], mimeTypes: string[] | null, text: string | null, subject: string | null, title: string | null, withResult: boolean, result: MethodResult): Promise<void> {
    Log.i(TAG, "shareFiles");
    if (this.isSharing || this.shareController != null) {
      Log.e(TAG, 'a share operation is already in progress');
      if (withResult) {
        result.error('share_error', 'a share operation is already in progress', null);
      }
      return;
    }
    this.isSharing = true;
    try {
      const cacheCleared = await this.clearShareCacheFolder();
      if (!cacheCleared) {
        // Surface the failure instead of silently continuing — copying the
        // new files into a half-cleared folder is unsafe.
        Log.e(TAG, 'failed to clear the share cache folder');
        if (withResult) {
          result.error('share_error', 'failed to clear share cache folder', null);
        }
        return;
      }
      let fileUris = await this.getUrisForPaths(paths)
      let data: systemShare.SharedData | null = null;
      if (fileUris.length == 0 && text != null && text.length !== 0) {
        // No files produced — delegate to the plain text share. Release the
        // guard first so share()'s own concurrency check lets this through.
        this.isSharing = false;
        this.share(text, subject, title, withResult, result)
        return
      } else if (fileUris.length == 1) {
        const mimeType = (mimeTypes != null && mimeTypes.length > 0) ? mimeTypes[0] : null;
        let record: systemShare.SharedRecord = {
          utd: this.getUniformTypeDescriptor(fileUris![0], mimeType),
          uri: fileUris[0],
          content: text ?? '',
          title: title || subject || '',
        }
        data = new systemShare.SharedData(record);
      } else {
        if (text != null && text.length !== 0) {
          let record: systemShare.SharedRecord = {
            utd: uniformTypeDescriptor.getUniformDataTypeByMIMEType('text/plain'),
            content: text,
            title: title || subject || '',
          }
          data = new systemShare.SharedData(record);
        }
        fileUris.forEach((uri: string, index: number) => {
          const mt = (mimeTypes != null && index < mimeTypes.length) ? mimeTypes[index] : null;
          let record: systemShare.SharedRecord = {
            utd: this.getUniformTypeDescriptor(uri, mt),
            uri: uri,
          }
          if (data) {
            data.addRecord(record);
          } else {
            data = new systemShare.SharedData(record);
          }
        })
      }
      if (data != null) {
        this.startShare(data, withResult, result);
      } else {
        // Neither the files nor the text produced a shareable record.
        Log.e(TAG, 'no shareable content produced');
        if (withResult) {
          result.error('share_error', 'no shareable content produced', null);
        }
      }
    } catch (err) {
      Log.e(TAG, 'shareFiles err:' + JSON.stringify(err));
      if (withResult) {
        result.error('share_error', 'share files failed: ' + JSON.stringify(err), null);
      }
    } finally {
      this.isSharing = false;
    }
  }

  private startShare(data: systemShare.SharedData, withResult: boolean, result: MethodResult): void {
    Log.i(TAG, "startShare");
    try {
      let controller = new systemShare.ShareController(data);
      if (withResult) {
        // Track the controller and keep the callback in a field so the SAME
        // reference can be passed to controller.off('dismiss') later — an
        // inline arrow function could never be unregistered, leaking the
        // listener (and `result`). Non-result shares have no dismiss callback
        // and therefore cannot be tracked; they are not registered here so
        // they never block a subsequent share.
        this.shareController = controller;
        this.dismissCallback = () => {
          result.success('');
          this.unregisterDismissListener();
        };
        controller.on('dismiss', this.dismissCallback);
      }
      // The sheet must be anchored to the ability's UI context; fail with a
      // clear error instead of passing an undefined context to show() when
      // the plugin is not attached to an ability.
      const hostContext = this.ability?.context;
      if (hostContext == null) {
        throw new Error('no UIAbility context available to show the share sheet');
      }
      controller.show(hostContext, {
        previewMode: systemShare.SharePreviewMode.DETAIL,
        selectionMode: systemShare.SelectionMode.BATCH
      });
    } catch (err) {
      Log.e(TAG, 'startShare err:' + JSON.stringify(err));
      this.unregisterDismissListener();
      if (withResult) {
        result.error('share_error', 'show share sheet failed: ' + JSON.stringify(err), null);
      }
    }
  }

  private unregisterDismissListener(): void {
    if (this.shareController != null && this.dismissCallback != null) {
      this.shareController.off('dismiss', this.dismissCallback);
    }
    this.shareController = null;
    this.dismissCallback = null;
  }

  private getUniformTypeDescriptor(fileUri: string, mimeType?: string | null): string {
    // Prefer the explicit MIME type (passed by Dart side) for UTD resolution,
    // falling back to the file extension when no MIME type is available.
    if (mimeType != null) {
      const utd = uniformTypeDescriptor.getUniformDataTypeByMIMEType(mimeType);
      if (utd != null) {
        return utd;
      }
    }
    const dotIndex = fileUri.lastIndexOf('.');
    if (dotIndex != -1) {
      const fileExtension = '.' + fileUri.substring(dotIndex + 1);
      return uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(fileExtension) ?? 'general.file';
    }
    return 'general.file';
  }

  private shareCacheFolder(): string {
    Log.i(TAG, "shareCacheFolder");
    return this.context?.cacheDir + '/share_plus';
  }

  private async getUrisForPaths(paths: string[]): Promise<Array<string>> {
    Log.i(TAG, "getUrisForPaths");
    let uris = new Array<string>();
    // IMPORTANT: must use a for-loop (not forEach) because the body is async.
    // Array.forEach does not await its callback, so uris would be empty on
    // return, silently breaking file sharing. Errors propagate to the caller
    // (shareFiles) which logs and replies.
    for (let i = 0; i < paths.length; i++) {
      let path = paths[i];
      if (this.fileIsInShareCache(path)) {
        throw new Error(`Shared file can not be located in '${this.shareCacheFolder()}'`);
      }
      let file = await this.copyToShareCacheFolder(path);
      uris.push(fileUri.getUriFromPath(file));
    }
    return uris
  }

  private fileIsInShareCache(file: string): boolean {
    Log.i(TAG, "fileIsInShareCache");
    let openedFile: fs.File | null = null;
    try {
      openedFile = fs.openSync(file);
      let filePathFold = openedFile.getParent();
      if (filePathFold.startsWith(this.shareCacheFolder())) {
        return true;
      }
    } catch (err) {
      Log.e(TAG, 'err:' + JSON.stringify(err));
    } finally {
      // The fd must be released on every path, including the error path.
      if (openedFile != null) {
        fs.closeSync(openedFile);
      }
    }
    return false;
  }

  private async clearShareCacheFolder(): Promise<boolean> {
    Log.i(TAG, "clearShareCacheFolder");
    try {
      let folder: string = this.shareCacheFolder();
      if (fs.accessSync(folder)) {
        let files = fs.listFileSync(folder);
        if (files.length > 0) {
          files.forEach(item => {
            fs.unlinkSync(folder + '/' + item);
          })
          fs.rmdirSync(folder);
        }
      }
    } catch (err) {
      Log.e(TAG, 'err:' + JSON.stringify(err));
      // Report the failure so the caller can decide whether to continue.
      return false;
    }
    return true;
  }

  private async copyToShareCacheFolder(file: string): Promise<string> {
    Log.i(TAG, "copyToShareCacheFolder");
    let folder = this.shareCacheFolder();
    if (!fs.accessSync(folder)) {
      fs.mkdirSync(folder);
    }
    // Critical path: fs APIs throw on failure. Errors propagate to the caller
    // (getUrisForPaths -> shareFiles) which logs and replies to Dart; the fd
    // is closed on every path via try-finally.
    let oldFile: fs.File | null = null;
    try {
      oldFile = fs.openSync(file);
      const newFile = folder + '/' + oldFile.name;
      fs.copyFileSync(oldFile.fd, newFile);
      return newFile;
    } finally {
      if (oldFile != null) {
        fs.closeSync(oldFile);
      }
    }
  }
}
