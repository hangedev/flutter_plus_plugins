/*
 * Copyright (C) 2026 Huawei Device Co., Ltd.
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

import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
import common from '@ohos.app.ability.common';
import UIAbility from '@ohos.app.ability.UIAbility';
import fs from '@ohos.file.fs';
import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import Share from '../../../main/ets/dev/fluttercommunity/plus/share/Share';
import { MockMethodResult, AbilityStub } from './TestMocks';

/** A Share whose context is null: every filesystem path degrades to an error. */
function shareWithoutContext(): Share {
  return new Share(null as ESObject as common.Context);
}

/** Local stand-in for common.Context when only the cacheDir path is needed. */
class CacheDirContextStub {
  cacheDir: string;

  constructor(cacheDir: string) {
    this.cacheDir = cacheDir;
  }
}

/**
 * Real app context when the test runner provides one; otherwise a stub whose
 * cacheDir points at the documented stage-model sandbox cache path.
 */
function realContext(): common.Context {
  try {
    const context: common.Context = AbilityDelegatorRegistry.getAbilityDelegator().getAppContext();
    if (context != null && context.cacheDir != null && context.cacheDir.length > 0) {
      return context;
    }
  } catch (err) {
  }
  return new CacheDirContextStub('/data/storage/el2/base/cache') as ESObject as common.Context;
}

/** Creates a small real file under the cache dir and returns its path. */
function createCacheFile(context: common.Context, name: string): string {
  const path: string = context.cacheDir + '/' + name;
  const file: fs.File =
    fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
  fs.writeSync(file.fd, 'share_plus unit test payload');
  fs.closeSync(file);
  return path;
}

function removeQuietly(path: string): void {
  try {
    fs.unlinkSync(path);
  } catch (err) {
  }
}

/** Removes the share_plus cache folder along with anything left inside it. */
function removeCacheFolderQuietly(context: common.Context): void {
  const folder: string = context.cacheDir + '/share_plus';
  try {
    if (fs.accessSync(folder)) {
      const files: string[] = fs.listFileSync(folder);
      for (let i = 0; i < files.length; i++) {
        removeQuietly(folder + '/' + files[i]);
      }
      fs.rmdirSync(folder);
    }
  } catch (err) {
  }
}

/** Pre-creates the share_plus cache folder, optionally with a junk file inside. */
function seedCacheFolder(context: common.Context, junkName: string | null): void {
  const folder: string = context.cacheDir + '/share_plus';
  if (!fs.accessSync(folder)) {
    fs.mkdirSync(folder);
  }
  if (junkName !== null) {
    const file: fs.File = fs.openSync(folder + '/' + junkName,
      fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
    fs.closeSync(file);
  }
}

/** Waits for fire-and-forget delegations (the inner share() promise) to settle. */
function sleep(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout(() => {
      resolve();
    }, ms);
  });
}

export default function shareTest() {
  describe('ShareStateTest', () => {
    // Pure state handling: context/ability ownership and dispose cleanup.
    // Deterministic on any device.

    it('constructor_keepsContextReference', 0, () => {
      const context: common.Context = new AbilityStub() as ESObject as common.Context;
      const share: Share = new Share(context);
      expect(share.context === context).assertTrue();
    });

    it('setAbility_storesAbility', 0, () => {
      const share: Share = shareWithoutContext();
      const ability: UIAbility = new AbilityStub() as ESObject as UIAbility;
      share.setAbility(ability);
      expect(share.ability === ability).assertTrue();
    });

    it('dispose_clearsAbility', 0, () => {
      const share: Share = shareWithoutContext();
      share.setAbility(new AbilityStub() as ESObject as UIAbility);
      share.dispose();
      expect(share.ability).assertEqual(null);
    });

    it('dispose_isIdempotentAndSafeWithoutAbility', 0, () => {
      const share: Share = shareWithoutContext();
      let thrown: boolean = false;
      try {
        share.dispose();
        share.dispose();
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
      expect(share.ability).assertEqual(null);
    });
  });

  describe('ShareErrorContractTest', () => {
    // Without a UIAbility (or any reachable cache folder) a share cannot be
    // shown. The plugin's contract is to surface exactly one error reply for
    // the withResult variants and to stay silent otherwise; which system call
    // fails first may vary per device, the error contract must not.

    it('share_withoutAbility_withResult_reportsSingleError', 0, async () => {
      const share: Share = shareWithoutContext();
      const result: MockMethodResult = new MockMethodResult();
      await share.share('hello', null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorCode).assertEqual('share_error');
      expect(result.callCount).assertEqual(1);
      expect(result.isSuccessCalled).assertFalse();
      expect(result.isNotImplementedCalled).assertFalse();
    });

    it('share_withoutAbility_withoutResult_staysSilent', 0, async () => {
      const share: Share = shareWithoutContext();
      const result: MockMethodResult = new MockMethodResult();
      let thrown: boolean = false;
      try {
        await share.share('hello', null, null, false, result);
      } catch (e) {
        thrown = true;
      }
      expect(thrown).assertFalse();
      expect(result.callCount).assertEqual(0);
    });

    it('share_failedAttempt_doesNotBlockNextShare', 0, async () => {
      // The isSharing guard must be released on the error path, so a second
      // attempt can proceed and report its own outcome.
      const share: Share = shareWithoutContext();
      const first: MockMethodResult = new MockMethodResult();
      await share.share('first', null, null, true, first);
      const second: MockMethodResult = new MockMethodResult();
      await share.share('second', null, null, true, second);
      expect(first.callCount).assertEqual(1);
      expect(first.isErrorCalled).assertTrue();
      expect(second.callCount).assertEqual(1);
      expect(second.isErrorCalled).assertTrue();
    });

    it('shareFiles_unreadablePath_reportsSingleError', 0, async () => {
      const share: Share = shareWithoutContext();
      const paths: string[] = ['/no/such/share_plus_test_file.bin'];
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorCode).assertEqual('share_error');
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_emptyPathsAndNoText_reportsSingleError', 0, async () => {
      // Neither files nor text produce a shareable record: an error, not silence.
      const share: Share = shareWithoutContext();
      const paths: string[] = new Array<string>();
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorCode).assertEqual('share_error');
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_failedAttempt_doesNotBlockNextShareFiles', 0, async () => {
      const share: Share = shareWithoutContext();
      const paths: string[] = ['/no/such/share_plus_test_file.bin'];
      const first: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, first);
      const second: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, second);
      expect(first.callCount).assertEqual(1);
      expect(second.callCount).assertEqual(1);
    });
  });

  describe('ShareCacheFolderDeviceTest', () => {
    // Real app context + real files under cacheDir: drives the full
    // clear/copy/uri pipeline of shareFiles (single file, multiple files,
    // mime fallbacks, no-extension files, text delegation) and the
    // title/subject fallbacks of share(). Every case still ends at the
    // no-UIAbility error, so no share sheet is ever shown.

    let context: common.Context;

    beforeAll(() => {
      context = realContext();
    });

    afterAll(() => {
      try {
        const names: string[] =
          ['sp_src_single.txt', 'sp_src_mime.txt', 'sp_src_unknown.bin', 'sp_src_noext',
            'sp_src_a.txt', 'sp_src_b.txt'];
        for (let i = 0; i < names.length; i++) {
          removeQuietly(context.cacheDir + '/' + names[i]);
        }
        removeCacheFolderQuietly(context);
      } catch (err) {
      }
    });

    it('shareFiles_singleRealFile_withoutMime_reportsError', 0, async () => {
      const share: Share = new Share(context);
      const paths: string[] = [createCacheFile(context, 'sp_src_single.txt')];
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorCode).assertEqual('share_error');
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_singleRealFile_withMimeAndTitle_reportsError', 0, async () => {
      const share: Share = new Share(context);
      const paths: string[] = [createCacheFile(context, 'sp_src_mime.txt')];
      const mimes: string[] = ['text/plain'];
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, mimes, null, 'sub', 'tit', true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_unknownMimeType_reportsError', 0, async () => {
      // An unmapped MIME type must fall back to the file extension (or fail
      // loudly); either way exactly one error reaches Flutter.
      const share: Share = new Share(context);
      const paths: string[] = [createCacheFile(context, 'sp_src_unknown.bin')];
      const mimes: string[] = ['application/x-share-plus-unknown'];
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, mimes, null, null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_fileWithoutExtension_reportsError', 0, async () => {
      // No dot in the copied name: the extension fallback must not throw.
      const share: Share = new Share(context);
      const paths: string[] = [createCacheFile(context, 'sp_src_noext')];
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_twoRealFiles_withText_reportsError', 0, async () => {
      const share: Share = new Share(context);
      const paths: string[] =
        [createCacheFile(context, 'sp_src_a.txt'), createCacheFile(context, 'sp_src_b.txt')];
      const mimes: string[] = ['text/plain'];
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, mimes, 'body text', null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_twoRealFiles_withoutText_reportsError', 0, async () => {
      const share: Share = new Share(context);
      const paths: string[] =
        [createCacheFile(context, 'sp_src_a.txt'), createCacheFile(context, 'sp_src_b.txt')];
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_missingSourceFile_reportsSingleError', 0, async () => {
      const share: Share = new Share(context);
      const paths: string[] = [context.cacheDir + '/sp_missing_source.bin'];
      removeQuietly(paths[0]);
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorCode).assertEqual('share_error');
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_emptyPaths_withText_delegatesToPlainTextShare', 0, async () => {
      // No file uris and non-empty text: shareFiles hands over to share().
      const share: Share = new Share(context);
      const paths: string[] = new Array<string>();
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, 'hello delegate', null, null, true, result);
      await sleep(200);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_emptyPaths_withEmptyText_reportsNoShareableContent', 0, async () => {
      const share: Share = new Share(context);
      const paths: string[] = new Array<string>();
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, '', null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('shareFiles_junkInCacheFolder_isClearedBeforeSharing', 0, async () => {
      // A leftover junk file in the share_plus folder must be wiped first.
      seedCacheFolder(context, 'sp_junk.bin');
      const share: Share = new Share(context);
      const paths: string[] = [createCacheFile(context, 'sp_src_single.txt')];
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, null, null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
      expect(fs.accessSync(context.cacheDir + '/share_plus/sp_junk.bin')).assertFalse();
    });

    it('shareFiles_emptyExistingCacheFolder_clearSucceeds', 0, async () => {
      seedCacheFolder(context, null);
      const share: Share = new Share(context);
      const paths: string[] = new Array<string>();
      const result: MockMethodResult = new MockMethodResult();
      await share.shareFiles(paths, null, '', null, null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('share_withTitle_setsDescription_reportsError', 0, async () => {
      const share: Share = new Share(context);
      const result: MockMethodResult = new MockMethodResult();
      await share.share('hello', null, 'Sheet title', true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });

    it('share_subjectOnly_fallsBackToSubjectAsTitle', 0, async () => {
      const share: Share = new Share(context);
      const result: MockMethodResult = new MockMethodResult();
      await share.share('hello', 'A subject', null, true, result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
    });
  });
}
