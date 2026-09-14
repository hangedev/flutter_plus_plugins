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
import { MethodCall } from '@ohos/flutter_ohos';
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import Share from './Share';

const TAG = 'MethodCallHandlerImpl';

export default class MethodCallHandlerImpl implements MethodCallHandler {
  private share: Share | null = null;

  constructor(share: Share) {
    this.share = share;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    Log.i(TAG, "onMethodCall step in");
    let method: string = call.method;
    Log.i(TAG, "Received '" + method + "' message.");

    // --- Input validation (mirrors iOS guards) ---
    // Reject empty text/uri/paths early to avoid undefined behaviour downstream.
    const text = call.argument('text') as string | null;
    if (text != null && text.length === 0) {
      result.error('error', 'Non-empty text expected', null);
      return;
    }
    const uri = call.argument('uri') as string | null;
    if (uri != null && uri.length === 0) {
      result.error('error', 'Non-empty uri expected', null);
      return;
    }
    const title = call.argument('title') as string | null;
    if (title != null && title.length === 0) {
      result.error('error', 'Non-empty title expected', null);
      return;
    }
    const paths = call.argument('paths') as string[] | null;
    if (paths != null && paths.length === 0) {
      result.error('error', 'Non-empty paths expected', null);
      return;
    }
    const mimeTypes = call.argument('mimeTypes') as string[] | null;
    // Mirror the iOS guard: paths and mimeTypes must be parallel arrays.
    if (mimeTypes != null && paths != null && mimeTypes.length !== paths.length) {
      result.error('error', 'Paths and mimeTypes should have same length', null);
      return;
    }

    // --- Result tracking ---
    // The Dart side always invokes the plain 'share'/'shareFiles'/'shareUri'
    // methods on OHOS (never the *WithResult variants). To match Android's
    // behaviour — where the share Future resolves with dismissed/unavailable
    // instead of always unavailable — result-tracking is enabled for all
    // three: startShare wires a dismiss callback on the ShareController, so
    // the Dart Future resolves when the user closes the share sheet.
    const isWithResult: boolean = call.method.endsWith('WithResult') ||
      call.method === 'share' || call.method === 'shareFiles' ||
      call.method === 'shareUri';
    try {
      switch (method) {
        case 'shareUri':
        case 'shareUriWithResult':
          if (uri == null) {
            result.error('error', 'uri is required for shareUri', null);
            return;
          }
          this.share?.share(uri, null, title, isWithResult, result);
          if (!isWithResult) {
            result.success("dev.fluttercommunity.plus/share/unavailable");
          }
          break;
        case 'share':
        case 'shareWithResult':
          if (text == null) {
            result.error('error', 'text is required for share', null);
            return;
          }
          this.share?.share(
            text,
            call.argument('subject') as string | null,
            title,
            isWithResult,
            result);
          if (!isWithResult) {
            result.success("dev.fluttercommunity.plus/share/unavailable");
          }
          break;
        case 'shareFiles':
        case 'shareFilesWithResult':
          if (paths == null) {
            result.error('error', 'paths is required for shareFiles', null);
            return;
          }
          this.share?.shareFiles(
            paths,
            mimeTypes,
            text,
            call.argument('subject') as string | null,
            title,
            isWithResult,
            result);
          if (!isWithResult) {
            result.success("dev.fluttercommunity.plus/share/unavailable");
          }
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (err) {
      Log.e(TAG, 'err:' + JSON.stringify(err));
      // Propagate the failure back to the Dart side so the pending
      // share Future resolves with a PlatformException instead of hanging.
      // Safe to reply here: a synchronous throw is only reachable before any
      // result.success(...) line in the switch above, so `result` is still
      // unreplied at this point.
      result.error('share_error', 'share failed: ' + JSON.stringify(err), null);
    }
  }
}
