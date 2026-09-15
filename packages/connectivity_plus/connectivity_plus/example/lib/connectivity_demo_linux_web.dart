// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// web 构建占位：Linux 平台插件经条件导出仅在非 web 构建下可见，
// 本文件仅保证 web 构建可编译；调用方在 web 下不会调用本函数。
Future<void> runLinuxPlatformDemo() async {}
