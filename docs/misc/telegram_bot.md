# Test Bot web Service Telegram

#### Curl Test
```bash
curl -s  -X POST \ https://api.telegram.org/bot<BOT_TOKEN>/getUpdates
## send message with keyboard
curl -s -X GET "https://api.telegram.org/bot<BOT_TOKEN>/sendMessage" -d "chat_id=<CHAT_ID>&text=send phon number ? " -d "reply_markup={\"keyboard\": [[{\"text\":\"phon number \",\"request_contact\" :true}]]}"
curl -s -X GET "https://api.telegram.org/bot<BOT_TOKEN>/sendMessage" -d "chat_id=<CHAT_ID>&text=send phon number ? " -d "reply_markup={\"keyboard\": [[{\"text\":\"phon number \",\"request_contact\" :true}],[{\"text\" :\"text2\"}]]}"

curl -s -X GET "https://api.telegram.org/bot<BOT_TOKEN>/sendMessage" -d "chat_id=<CHAT_ID>&text=tanx " -d "reply_markup={\"remove_keyboard\":true}"

curl -s -X POST https://api.telegram.org/bot<BOT_TOKEN>/sendMessage -H "Content-Type: application/json" -d "{\"chat_id\": <CHAT_ID>, \"text\": \"tanx\"}"
curl -s   -X POST   https://api.telegram.org/bot<BOT_TOKEN>/getMe
curl -X POST "https://api.telegram.org/bot<BOT_TOKEN>/sendMessage" -d chat_id=<CHAT_ID> -d text="Hello World"
```
#### Web Browser Test
```text
https://api.telegram.org/bot<BOT_TOKEN>/getme
https://api.telegram.org/bot<BOT_TOKEN>/getUpdates
https://api.telegram.org/bot<BOT_TOKEN>/sendMessage?chat_id=<CHAT_ID>&text=Hello%20World

https://api.telegram.org/bot<BOT_TOKEN>/sendmessage?chat_id=<CHAT_ID>&text=testbtn&reply_markup={"keyboard": [[{"text" :"text1"}],[{"text" :"text2"}]]}
```
