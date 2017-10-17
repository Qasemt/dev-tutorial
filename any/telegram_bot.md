## Test Bot web Service Telegram 

#### Curl Test
```
curl -s  -X POST \ https://api.telegram.org/bot351972893****************A1-6UKY-Q***/getUpdates  
## send message with keyboard
curl -s -X GET "https://api.telegram.org/bot351972893****************A1-6UKY-Q***/sendMessage" -d "chat_id=*********&text=send phon number ? " -d "reply_markup={\"keyboard\": [[{\"text\":\"phon number \",\"request_contact\" :true}]]}"
curl -s -X GET "https://api.telegram.org/bot351972893****************A1-6UKY-Q***/sendMessage" -d "chat_id=*********&text=send phon number ? " -d "reply_markup={\"keyboard\": [[{\"text\":\"phon number \",\"request_contact\" :true}],[{\"text\" :\"text2\"}]]}"

curl -s -X GET "https://api.telegram.org/bot351972893****************A1-6UKY-Q***/sendMessage" -d "chat_id=*********&text=tanx " -d "reply_markup={\"remove_keyboard\":true}"

curl -s -X POST https://api.telegram.org/bot351972893****************A1-6UKY-Q***/sendMessage -H "Content-Type: application/json" -d "{\"chat_id\": *********, \"text\": \"tanx\"}" 
curl -s   -X POST   https://api.telegram.org/bot351972893****************A1-6UKY-Q***/getMe 
curl -X POST "https://api.telegram.org/bot351972893****************A1-6UKY-Q***/sendMessage" -d chat_id=4234234 -d text="Hello World"
```
#### Web Browser Test
```
https://api.telegram.org/bot351972893****************A1-6UKY-Q***/getme
https://api.telegram.org/bot351972893****************A1-6UKY-Q***/getUpdates
https://api.telegram.org/bot351972893****************A1-6UKY-Q***/sendMessage?chat_id=*********&text=Hello%20World

https://api.telegram.org/bot347803164:AAEg**************KweblvdP25sYIqpeQ/sendmessage?chat_id=*********&text=testbtn&reply_markup={"keyboard": [[{"text" :"text1"}],[{"text" :"text2"}]]}
```
