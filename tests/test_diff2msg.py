# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

from gitted.diff2msg import (
    generate_commit_message,
    is_summarizable_chunk,
    prepare_diff,
)


class TestIsSummarizableChunk:
    def test_include_text_file(self):
        diff = """\
diff --git a/file.txt b/file.txt
index e69de29..d95f3ad 100644
--- a/file.txt
+++ b/file.txt
@@ -0,0 +1 @@
+content
"""
        result = is_summarizable_chunk(diff)
        assert result

    def test_include_new_file(self):
        diff = """\
diff --git a/new_file.txt b/new_file.txt
new file mode 100644
index 0000000..d95f3ad
--- /dev/null
+++ b/new_file.txt
@@ -0,0 +1 @@
+content
"""
        result = is_summarizable_chunk(diff)
        assert result

    def test_exclude_svg_files(self):
        diff = """\
diff --git a/file.svg b/file.svg
index e69de29..ca56cec 100644
--- a/file.svg
+++ b/file.svg
@@ -0,0 +1,3 @@
+<svg width="100" height="100">
+  <content/>
+</svg>
"""
        result = is_summarizable_chunk(diff)
        assert not result

    def test_exclude_binary_files(self):
        diff = """\
diff --git a/img.png b/img.png
index 18f214a..6dcf534 100644
Binary files a/img.png and b/img.png differ
"""
        result = is_summarizable_chunk(diff)
        assert not result

    def test_handle_filenames_with_spaces(self):
        diff = """\
diff --git a/new file.txt b/new file.txt
index e69de29..d95f3ad 100644
--- a/new file.txt
+++ b/new file.txt
@@ -0,0 +1 @@
+content
"""
        result = is_summarizable_chunk(diff)
        assert result

    def test_handle_files_without_extension(self):
        diff = """\
diff --git a/Dockerfile b/Dockerfile
index e69de29..d95f3ad 100644
--- a/Dockerfile
+++ b/Dockerfile
@@ -0,0 +1 @@
+FROM python:3.9
"""
        result = is_summarizable_chunk(diff)
        assert result

    def test_handle_files_with_multiple_dots(self):
        diff = """\
diff --git a/config.test.js b/config.test.js
index e69de29..d95f3ad 100644
--- a/config.test.js
+++ b/config.test.js
@@ -0,0 +1 @@
+module.exports = {};
"""
        result = is_summarizable_chunk(diff)
        assert result

    def test_handle_files_in_subdirectories(self):
        diff = """\
diff --git a/src/hello/main.py b/src/hello/main.py
index e69de29..d95f3ad 100644
--- a/src/hello/main.py
+++ b/src/hello/main.py
@@ -0,0 +1,3 @@
+def hello():
+    print("Hello, World!")
+
"""
        result = is_summarizable_chunk(diff)
        assert result

    def test_raise_error_when_header_is_invalid(self):
        import pytest
        diff = """\
some malformed diff header
index e69de29..d95f3ad 100644
--- a/file.txt
+++ b/file.txt
@@ -0,0 +1 @@
+content
"""
        with pytest.raises(ValueError, match="Invalid diff chunk format"):
            is_summarizable_chunk(diff)


class TestPrepareDiff:
    def test_return_empty_string_for_empty_input(self):
        result = prepare_diff("")
        assert result == ""

    def test_handle_single_chunk_diff(self, monkeypatch):
        monkeypatch.setattr('gitted.diff2msg.is_summarizable_chunk',
                            lambda x: True)
        diff = """\
diff --git a/file.txt b/file.txt
index e69de29..d95f3ad 100644
--- a/file.txt
+++ b/file.txt
@@ -0,0 +1 @@
+content
"""
        result = prepare_diff(diff)
        assert result == diff

    def test_handle_multiple_chunks_diff(self, monkeypatch):
        monkeypatch.setattr('gitted.diff2msg.is_summarizable_chunk',
                            lambda x: True)
        diff = """\
diff --git a/file1.txt b/file1.txt
index e69de29..d95f3ad 100644
--- a/file1.txt
+++ b/file1.txt
@@ -0,0 +1 @@
+content1
diff --git a/file2.txt b/file2.txt
index e69de29..d95f3ad 100644
--- a/file2.txt
+++ b/file2.txt
@@ -0,0 +1 @@
+content2
"""
        result = prepare_diff(diff)
        assert result == diff

    def test_return_empty_when_no_chunks_are_summarizable(self, monkeypatch):
        monkeypatch.setattr('gitted.diff2msg.is_summarizable_chunk',
                            lambda x: False)
        diff = """\
diff --git a/image1.svg b/image1.svg
index e69de29..ca56cec 100644
--- a/image1.svg
+++ b/image1.svg
@@ -0,0 +1 @@
+<svg>content</svg>
diff --git a/image2.png b/image2.png
index 18f214a..6dcf534 100644
Binary files a/image2.png and b/image2.png differ
"""
        result = prepare_diff(diff)
        assert result == ""


class TestDiff2Msg:
    def test_empty_diff(self):
        result = generate_commit_message('')
        assert result == 'No changes'
        result = generate_commit_message('   ')
        assert result == 'No changes'

    def test_testing_mode(self, monkeypatch):
        monkeypatch.setenv('GITTED_TESTING', 'true')
        diff = """\
diff --git a/file.txt b/file.txt
index e69de29..d95f3ad 100644
--- a/file.txt
+++ b/file.txt
@@ -0,0 +1 @@
+content
"""
        result = generate_commit_message(diff, 'test message')
        assert result == 'test message'
        result = generate_commit_message(diff)
        assert result == ''

    def test_openai_call(self, monkeypatch):
        monkeypatch.delenv('GITTED_TESTING', raising=False)

        class MockMessage:
            def __init__(self):
                self.content = 'Add new feature'

        class MockChoice:
            def __init__(self):
                self.message = MockMessage()

        class MockResponse:
            def __init__(self):
                self.choices = [MockChoice()]

        class MockCompletions:
            def create(self, **kwargs):
                assert kwargs['model'] == 'gpt-3.5-turbo'
                assert kwargs['max_tokens'] == 100
                assert kwargs['temperature'] == 0.7
                return MockResponse()

        class MockChat:
            def __init__(self):
                self.completions = MockCompletions()

        class MockClient:
            def __init__(self):
                self.chat = MockChat()

        monkeypatch.setattr('gitted.diff2msg.OpenAI', MockClient)
        diff = """\
diff --git a/test.py b/test.py
new file mode 100644
index 0000000..1234567
--- /dev/null
+++ b/test.py
@@ -0,0 +1,3 @@
+def hello():
+    print("Hello, World!")
+
"""
        result = generate_commit_message(diff)
        assert result == 'Add new feature'

    def test_openai_call_with_message(self, monkeypatch):
        monkeypatch.delenv('GITTED_TESTING', raising=False)
        captured_messages = []

        class MockMessage:
            def __init__(self):
                self.content = 'Fix bug in authentication'

        class MockChoice:
            def __init__(self):
                self.message = MockMessage()

        class MockResponse:
            def __init__(self):
                self.choices = [MockChoice()]

        class MockCompletions:
            def create(self, **kwargs):
                captured_messages.append(kwargs['messages'][0]['content'])
                return MockResponse()

        class MockChat:
            def __init__(self):
                self.completions = MockCompletions()

        class MockClient:
            def __init__(self):
                self.chat = MockChat()

        monkeypatch.setattr('gitted.diff2msg.OpenAI', MockClient)
        diff = """\
diff --git a/auth.py b/auth.py
index 1234567..abcdefg 100644
--- a/auth.py
+++ b/auth.py
@@ -10,7 +10,7 @@ def authenticate(user):
-    if user.password == stored_password:
+    if user.check_password(stored_password):
"""
        result = generate_commit_message(diff, 'fix auth')
        assert result == 'Fix bug in authentication'
        assert len(captured_messages) == 1
        assert 'fix auth' in captured_messages[0]
