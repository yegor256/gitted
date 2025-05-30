# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import os
from gitted.diff2msg import generate_commit_message


class TestDiff2Msg:
    def test_empty_diff(self):
        result = generate_commit_message('')
        assert result == 'No changes'
        result = generate_commit_message('   ')
        assert result == 'No changes'
    def test_testing_mode(self, monkeypatch):
        monkeypatch.setenv('GITTED_TESTING', 'true')
        result = generate_commit_message('some diff', 'test message')
        assert result == 'test message'
        result = generate_commit_message('some diff')
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
        diff = """diff --git a/test.py b/test.py
new file mode 100644
index 0000000..1234567
--- /dev/null
+++ b/test.py
@@ -0,0 +1,3 @@
+def hello():
+    print("Hello, World!")
+"""
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
        diff = """diff --git a/auth.py b/auth.py
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
