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

import { describe, it, expect } from '@ohos/hypium';
import MethodChannelHandlerImpl from '../../../main/ets/dev/fluttercommunity/plus/share/MethodChannelHandlerImpl';
import Share from '../../../main/ets/dev/fluttercommunity/plus/share/Share';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { MockMethodResult, RecordingShare } from './TestMocks';

/** Builds a MethodCall whose arguments arrive as a Map, as the codec delivers. */
function call(method: string, args: Map<string, ESObject> | null): MethodCall {
  return new MethodCall(method, args);
}

/** Builds the argument map used by the Dart side of share_plus. */
function textArgs(text: string | null, subject: string | null, title: string | null):
  Map<string, ESObject> {
  const args: Map<string, ESObject> = new Map<string, ESObject>();
  if (text !== null) {
    args.set('text', text);
  }
  if (subject !== null) {
    args.set('subject', subject);
  }
  if (title !== null) {
    args.set('title', title);
  }
  return args;
}

export default function methodChannelHandlerImplTest() {
  describe('MethodChannelHandlerImplValidationTest', () => {
    // Input guards mirroring the iOS implementation: empty text/uri/title/paths
    // and mismatched mimeTypes must be rejected before any share is started.

    it('emptyText_isRejectedBeforeSharing', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('share', textArgs('', null, null)), result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorCode).assertEqual('error');
      expect(result.errorMessage).assertEqual('Non-empty text expected');
      expect(result.callCount).assertEqual(1);
      expect(share.shareCallCount).assertEqual(0);
    });

    it('emptyUri_isRejectedBeforeSharing', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const args: Map<string, ESObject> = new Map<string, ESObject>();
      args.set('uri', '');
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('shareUri', args), result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorMessage).assertEqual('Non-empty uri expected');
      expect(result.callCount).assertEqual(1);
      expect(share.shareCallCount).assertEqual(0);
    });

    it('emptyTitle_isRejectedBeforeSharing', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('share', textArgs('hello', null, '')), result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorMessage).assertEqual('Non-empty title expected');
      expect(result.callCount).assertEqual(1);
      expect(share.shareCallCount).assertEqual(0);
    });

    it('emptyPaths_isRejectedBeforeSharing', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const args: Map<string, ESObject> = new Map<string, ESObject>();
      args.set('paths', new Array<string>());
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('shareFiles', args), result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorMessage).assertEqual('Non-empty paths expected');
      expect(result.callCount).assertEqual(1);
      expect(share.shareFilesCallCount).assertEqual(0);
    });

    it('mimeTypesLengthMismatch_isRejected', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const args: Map<string, ESObject> = new Map<string, ESObject>();
      const paths: string[] = ['/a.txt', '/b.txt'];
      const mimeTypes: string[] = ['text/plain'];
      args.set('paths', paths);
      args.set('mimeTypes', mimeTypes);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('shareFiles', args), result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorMessage).assertEqual('Paths and mimeTypes should have same length');
      expect(result.callCount).assertEqual(1);
      expect(share.shareFilesCallCount).assertEqual(0);
    });

    it('validationChecksTextBeforeUriAndTitle', 0, () => {
      // All guards would fire; the text guard must win because it runs first.
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const args: Map<string, ESObject> = new Map<string, ESObject>();
      args.set('text', '');
      args.set('uri', '');
      args.set('title', '');
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('share', args), result);
      expect(result.errorMessage).assertEqual('Non-empty text expected');
    });
  });

  describe('MethodChannelHandlerImplRoutingTest', () => {
    // Method dispatch: every known method must reach Share with the mapped
    // arguments; anything else must report notImplemented. The RecordingShare
    // double keeps these deterministic (no share sheet, no filesystem).

    it('unknownMethod_reportsNotImplemented', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('noSuchMethod', null), result);
      expect(result.isNotImplementedCalled).assertTrue();
      expect(result.callCount).assertEqual(1);
      expect(result.isSuccessCalled).assertFalse();
      expect(result.isErrorCalled).assertFalse();
      expect(share.shareCallCount + share.shareFilesCallCount).assertEqual(0);
    });

    it('methodMatchIsCaseSensitive', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('Share', textArgs('hello', null, null)), result);
      expect(result.isNotImplementedCalled).assertTrue();
      expect(share.shareCallCount).assertEqual(0);
    });

    it('share_withoutText_reportsTextRequired', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('share', textArgs(null, null, null)), result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorMessage).assertEqual('text is required for share');
      expect(result.callCount).assertEqual(1);
      expect(share.shareCallCount).assertEqual(0);
    });

    it('shareUri_withoutUri_reportsUriRequired', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('shareUri', new Map<string, ESObject>()), result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorMessage).assertEqual('uri is required for shareUri');
      expect(share.shareCallCount).assertEqual(0);
    });

    it('shareFiles_withoutPaths_reportsPathsRequired', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('shareFiles', textArgs('body', null, null)), result);
      expect(result.isErrorCalled).assertTrue();
      expect(result.errorMessage).assertEqual('paths is required for shareFiles');
      expect(share.shareFilesCallCount).assertEqual(0);
    });

    it('share_delegatesToShareWithResultTracking', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('share', textArgs('hello', 'sub', 'tit')), result);
      expect(share.shareCallCount).assertEqual(1);
      expect(share.shareFilesCallCount).assertEqual(0);
      expect(share.lastText).assertEqual('hello');
      expect(share.lastSubject).assertEqual('sub');
      expect(share.lastTitle).assertEqual('tit');
      expect(share.lastWithResult).assertTrue();
      // Result tracking is on: the reply stays pending until the share sheet
      // dismisses, so nothing is reported back on the call path itself.
      expect(result.callCount).assertEqual(0);
    });

    it('shareWithResult_delegatesToShareTheSameWay', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('shareWithResult', textArgs('hello', null, null)), result);
      expect(share.shareCallCount).assertEqual(1);
      expect(share.lastText).assertEqual('hello');
      expect(share.lastWithResult).assertTrue();
      expect(result.callCount).assertEqual(0);
    });

    it('shareUri_delegatesToShareWithUriAsContent', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const args: Map<string, ESObject> = new Map<string, ESObject>();
      args.set('uri', 'https://example.com');
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('shareUri', args), result);
      expect(share.shareCallCount).assertEqual(1);
      expect(share.lastText).assertEqual('https://example.com');
      expect(share.lastSubject).assertEqual(null);
      expect(share.lastWithResult).assertTrue();
    });

    it('shareFiles_delegatesArgumentsInOrder', 0, () => {
      const share: RecordingShare = new RecordingShare();
      const handler: MethodChannelHandlerImpl = new MethodChannelHandlerImpl(share);
      const args: Map<string, ESObject> = new Map<string, ESObject>();
      const paths: string[] = ['/a.txt', '/b.txt'];
      const mimeTypes: string[] = ['text/plain', 'application/pdf'];
      args.set('paths', paths);
      args.set('mimeTypes', mimeTypes);
      args.set('text', 'body');
      args.set('subject', 'sub');
      args.set('title', 'tit');
      const result: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('shareFiles', args), result);
      expect(share.shareFilesCallCount).assertEqual(1);
      expect(share.shareCallCount).assertEqual(0);
      expect(share.lastPaths!.length).assertEqual(2);
      expect(share.lastPaths![0]).assertEqual('/a.txt');
      expect(share.lastPaths![1]).assertEqual('/b.txt');
      expect(share.lastMimeTypes![1]).assertEqual('application/pdf');
      expect(share.lastText).assertEqual('body');
      expect(share.lastSubject).assertEqual('sub');
      expect(share.lastTitle).assertEqual('tit');
      expect(share.lastWithResult).assertTrue();
      expect(result.callCount).assertEqual(0);
    });

    it('handler_withNullShare_staysSilentForAllMethods', 0, () => {
      // The optional-chain guards must skip a missing Share instead of
      // throwing; with result tracking on, nothing is reported back either.
      const handler: MethodChannelHandlerImpl =
        new MethodChannelHandlerImpl(null as ESObject as Share);
      const textCall: MockMethodResult = new MockMethodResult();
      handler.onMethodCall(call('share', textArgs('hello', null, null)), textCall);
      const uriCall: MockMethodResult = new MockMethodResult();
      const uriArgs: Map<string, ESObject> = new Map<string, ESObject>();
      uriArgs.set('uri', 'https://example.com');
      handler.onMethodCall(call('shareUri', uriArgs), uriCall);
      const filesCall: MockMethodResult = new MockMethodResult();
      const fileArgs: Map<string, ESObject> = new Map<string, ESObject>();
      const paths: string[] = ['/a.txt'];
      fileArgs.set('paths', paths);
      handler.onMethodCall(call('shareFiles', fileArgs), filesCall);
      expect(textCall.callCount).assertEqual(0);
      expect(uriCall.callCount).assertEqual(0);
      expect(filesCall.callCount).assertEqual(0);
    });
  });
}
