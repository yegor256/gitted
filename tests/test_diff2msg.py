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

    def test_handle_quoted_filenames_with_unicode(self):
        diff = (
            'diff --git "a/eo-runtime/src/main/java/org/eolang/'
            'EOmalloc$EOof$EO\\317\\206.java" '
            '"b/eo-runtime/src/main/java/org/eolang/'
            'EOmalloc$EOof$EO\\317\\206.java"\n'
            'index e69de29..d95f3ad 100644\n'
            '--- a/file.java\n'
            '+++ b/file.java\n'
            '@@ -0,0 +1 @@\n'
            '+content\n'
        )
        result = is_summarizable_chunk(diff)
        assert result

    def test_exclude_quoted_svg_filename(self):
        diff = (
            'diff --git "a/dir/icon-\\317\\206.svg" '
            '"b/dir/icon-\\317\\206.svg"\n'
            'index e69de29..ca56cec 100644\n'
            '--- a/dir/icon.svg\n'
            '+++ b/dir/icon.svg\n'
            '@@ -0,0 +1 @@\n'
            '+<svg/>\n'
        )
        result = is_summarizable_chunk(diff)
        assert not result

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

    def test_exclude_large_lockfile_chunk(self):
        header = (
            "diff --git a/package-lock.json b/package-lock.json\n"
            "index e69de29..d95f3ad 100644\n"
            "--- a/package-lock.json\n"
            "+++ b/package-lock.json\n"
            "@@ -0,0 +1,600 @@\n"
        )
        body = "\n".join(f'+  "dep{i}": "^1.0.0",' for i in range(600))
        diff = header + body + "\n"
        result = is_summarizable_chunk(diff)
        assert not result

    def test_include_small_chunk(self):
        header = (
            "diff --git a/src/a.py b/src/a.py\n"
            "index e69de29..d95f3ad 100644\n"
            "--- a/src/a.py\n"
            "+++ b/src/a.py\n"
            "@@ -0,0 +1,10 @@\n"
        )
        body = "\n".join(f"+line {i}" for i in range(10))
        diff = header + body + "\n"
        result = is_summarizable_chunk(diff)
        assert result


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

    def test_drop_large_chunk_keep_small_ones(self):
        small = (
            "diff --git a/src/a.py b/src/a.py\n"
            "index e69de29..d95f3ad 100644\n"
            "--- a/src/a.py\n"
            "+++ b/src/a.py\n"
            "@@ -0,0 +1,1 @@\n"
            "+print('hi')\n"
        )
        big_header = (
            "diff --git a/package-lock.json b/package-lock.json\n"
            "index e69de29..d95f3ad 100644\n"
            "--- a/package-lock.json\n"
            "+++ b/package-lock.json\n"
            "@@ -0,0 +1,600 @@\n"
        )
        big_body = "\n".join(f'+  "dep{i}": "^1.0.0",' for i in range(600))
        diff = small + big_header + big_body + "\n"
        result = prepare_diff(diff)
        assert 'a/src/a.py' in result
        assert 'package-lock.json' not in result


class TestDiff2Msg:
    def test_empty_diff(self):
        result = generate_commit_message('')
        assert result == 'No changes'
        result = generate_commit_message('   ')
        assert result == 'No changes'

    def test_falls_back_to_user_message_when_diff_is_empty(self):
        result = generate_commit_message('', 'manual message')
        assert result == 'manual message'

    def test_falls_back_to_user_message_when_all_chunks_are_filtered(self):
        header = (
            "diff --git a/package-lock.json b/package-lock.json\n"
            "index e69de29..d95f3ad 100644\n"
            "--- a/package-lock.json\n"
            "+++ b/package-lock.json\n"
            "@@ -0,0 +1,600 @@\n"
        )
        body = "\n".join(f'+  "dep{i}": "^1.0.0",' for i in range(600))
        diff = header + body + "\n"
        result = generate_commit_message(diff, 'manual message')
        assert result == 'manual message'

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

    def test_retries_on_api_timeout_then_succeeds(self, monkeypatch):
        import time
        import httpx
        from openai import APITimeoutError
        monkeypatch.delenv('GITTED_TESTING', raising=False)
        sleeps = []
        monkeypatch.setattr(time, 'sleep', lambda s: sleeps.append(s))
        attempts = {'count': 0}

        class MockMessage:
            def __init__(self):
                self.content = 'Recovered after retry'

        class MockChoice:
            def __init__(self):
                self.message = MockMessage()

        class MockResponse:
            def __init__(self):
                self.choices = [MockChoice()]

        class MockCompletions:
            def create(self, **kwargs):
                attempts['count'] += 1
                if attempts['count'] < 3:
                    raise APITimeoutError(
                        request=httpx.Request(
                            'POST',
                            'https://api.openai.com/v1/chat/completions'
                        )
                    )
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
@@ -0,0 +1 @@
+x = 1
"""
        result = generate_commit_message(diff)
        assert result == 'Recovered after retry'
        assert attempts['count'] == 3
        assert len(sleeps) == 2

    def test_retries_on_api_connection_error_then_succeeds(self, monkeypatch):
        import time
        import httpx
        from openai import APIConnectionError
        monkeypatch.delenv('GITTED_TESTING', raising=False)
        monkeypatch.setattr(time, 'sleep', lambda s: None)
        attempts = {'count': 0}

        class MockMessage:
            def __init__(self):
                self.content = 'Fixed connection'

        class MockChoice:
            def __init__(self):
                self.message = MockMessage()

        class MockResponse:
            def __init__(self):
                self.choices = [MockChoice()]

        class MockCompletions:
            def create(self, **kwargs):
                attempts['count'] += 1
                if attempts['count'] < 2:
                    raise APIConnectionError(
                        request=httpx.Request(
                            'POST',
                            'https://api.openai.com/v1/chat/completions'
                        )
                    )
                return MockResponse()

        class MockChat:
            def __init__(self):
                self.completions = MockCompletions()

        class MockClient:
            def __init__(self):
                self.chat = MockChat()

        monkeypatch.setattr('gitted.diff2msg.OpenAI', MockClient)
        diff = """\
diff --git a/x.py b/x.py
index e69de29..d95f3ad 100644
--- a/x.py
+++ b/x.py
@@ -0,0 +1 @@
+y = 2
"""
        result = generate_commit_message(diff)
        assert result == 'Fixed connection'
        assert attempts['count'] == 2

    def test_raises_after_max_retries_exhausted(self, monkeypatch):
        import time
        import httpx
        import pytest
        from openai import APITimeoutError
        monkeypatch.delenv('GITTED_TESTING', raising=False)
        monkeypatch.setattr(time, 'sleep', lambda s: None)
        attempts = {'count': 0}

        class MockCompletions:
            def create(self, **kwargs):
                attempts['count'] += 1
                raise APITimeoutError(
                    request=httpx.Request(
                        'POST',
                        'https://api.openai.com/v1/chat/completions'
                    )
                )

        class MockChat:
            def __init__(self):
                self.completions = MockCompletions()

        class MockClient:
            def __init__(self):
                self.chat = MockChat()

        monkeypatch.setattr('gitted.diff2msg.OpenAI', MockClient)
        diff = """\
diff --git a/z.py b/z.py
index e69de29..d95f3ad 100644
--- a/z.py
+++ b/z.py
@@ -0,0 +1 @@
+z = 3
"""
        with pytest.raises(APITimeoutError):
            generate_commit_message(diff)
        assert attempts['count'] >= 2
