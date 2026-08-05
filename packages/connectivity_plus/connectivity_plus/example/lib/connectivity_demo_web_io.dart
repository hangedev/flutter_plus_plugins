// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// VM/OHOS 构建占位：Web 平台插件经条件导出仅在 web 构建下可见，
// 本文件仅保证非 web 构建可编译；调用方在非 web 平台不会调用本函数。
Future<void> runWebPlatformDemo() async {}
