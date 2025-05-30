# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import os
from unittest.mock import patch, MagicMock
from gitted.diff2msg import generate_commit_message


class TestDiff2Msg:
    def test_empty_diff(self):
        result = generate_commit_message('')
        assert result == 'No changes'
        result = generate_commit_message('   ')
        assert result == 'No changes'


    def test_testing_mode(self):
        with patch.dict(os.environ, {'GITTED_TESTING': 'true'}):
            result = generate_commit_message('some diff', 'test message')
            assert result == 'test message'
            result = generate_commit_message('some diff')
            assert result == ''


    @patch('gitted.diff2msg.OpenAI')
    def test_openai_call(self, mock_openai):
        mock_response = MagicMock()
        mock_response.choices = [MagicMock()]
        mock_response.choices[0].message.content = 'Add new feature'
        mock_client = MagicMock()
        mock_client.chat.completions.create.return_value = mock_response
        mock_openai.return_value = mock_client
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
        mock_client.chat.completions.create.assert_called_once()
        call_args = mock_client.chat.completions.create.call_args
        assert call_args[1]['model'] == 'gpt-3.5-turbo'
        assert call_args[1]['max_tokens'] == 100
        assert call_args[1]['temperature'] == 0.7


    @patch('gitted.diff2msg.OpenAI')
    def test_openai_call_with_message(self, mock_openai):
        mock_response = MagicMock()
        mock_response.choices = [MagicMock()]
        mock_response.choices[0].message.content = 'Fix bug in authentication'
        mock_client = MagicMock()
        mock_client.chat.completions.create.return_value = mock_response
        mock_openai.return_value = mock_client
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
        call_args = mock_client.chat.completions.create.call_args
        messages = call_args[1]['messages'][0]['content']
        assert 'fix auth' in messages
