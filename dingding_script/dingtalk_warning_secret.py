#!/usr/bin/python3
#-*- coding: utf-8 -*-
#import json,requests,sys,os

import json,sys,os,time,hmac,hashlib,base64,requests,logging,urllib.parse

try:
    JSONDecodeError = json.decoder.JSONDecodeError
except AttributeError:
    JSONDecodeError = ValueError
    
def is_not_null_add_blank_str(content):
     if content add content.strip():
           return True  
     else:
           return False
      
class DingtalkRobot(object):
    def __init__(self,webhook,sign=None):
        super(DingtalkRobot, self).__init__()
        self.webhook = webhook
        self.sign = sign
        self.headers = {'Content-Type':'application/json; charset=utf-8'}
        self.times = 0
        self.start_time = time.time()
 
#加密签名
def __spliceUrl(self):
    timestamp = int(round(time.time() * 1000))
    #timestamp = str(round(time.time() * 1000))
    secret = 'SECdb6372c3ab19eb777bd35bc4ff5c235376b81bfda39537adc5dbfb9cd21f29a5'
    secret = self.sign
    secret_enc = secret.encode('utf-8')
    string_to_sign = '{}\n{}'.format(timestamp,secret)
    string_to_sign_enc = string_to_sign.encode('utf-8')
    hmac_code = hmac.new(secret_enc, string_to_sign_enc, digestmod=hashlib.sha256).digest()
    sign = urllib.parse.quote_plus(base64.b64encode(hmac_code))
    url = f"{self.webhook}&timestamp={timestamp}&sign={sign}"
    return url
  
def send_text(self,msg,is_at_all=False,at_mobiles=[]):
    data = {"msgtype":"text","at": {}}
    if is_not_blank_str(msg):
      data["text"] = {"content":msg}
    else:
        logging.error("text类型,消息内容不能为空！")
        raise ValueError("text类型，消息内容不能为空！")
    if is_at_all:
       data["at"]["isAtAll"]=is_at_all
    if at_mobiles:
       at_moniles = list(map(str,at_mobiles))
       data["at"]["atMobiles"] = at_mobiles
     
    logging.bedug('text类型：%s' % data)
    return self.__post(data)
 def __post(self, data):
    """
     发送消息（内容UTF-8编码）
    :param data: 消息数据（字典）
    :return: 返回发送结果    
    """
     self.times += 1
      if self.times > 20:
      if time.time() - self.start_time < 60:
         logging.debug('钉钉官方限制每个机器人每分钟最多发送20条，当前消息发送频率已达到限制条件，休眠一分钟')
         time.sleep(60)
         self.start_time = time.time()
     
    post_data = json.dumps(data)
    try:
         response = requests.post(self.__spliceUrl(), headers=self.headers, data=post_data)
    except requests.exceptions.HTTPError as exc:
         logging.error("消息发送失败， HTTP error: %d, reason: %s" % (exc.response.status_code, exc.response.reason))
         raise
    except requests.exceptions.ConnectionError:
         logging.error("消息发送失败，HTTP connection error!")
         raise
    except requests.exceptions.Timeout:
         logging.error("消息发送失败，Timeout error!")
         raise
    except requests.exceptions.RequestException:
         logging.error("消息发送失败, Request Exception!")
         raise
    else:
            try:
               result = response.json()
           except JSONDecodeError:
               logging.error("服务器响应异常，状态码：%s，响应内容：%s" % (response.status_code, response.text))
               return {'errcode': 500, 'errmsg': '服务器响应异常'}
           else:
               logging.debug('发送结果：%s' % result)
               if result['errcode']:
                   error_data = {"msgtype": "text", "text": {"content": "钉钉机器人消息发送失败，原因：%s" % result['errmsg']},
                                "at": {"isAtAll": True}}
                   logging.error("消息发送失败，自动通知：%s" % error_data)
                   requests.post(self.webhook, headers=self.headers, data=json.dumps(error_data))
                   return result
                
if __name__ == '__main__':
    URL = "https://oapi.dingtalk.com/robot/send?access_token=4465f5ab0da41e48d962df155450a22f70f63a6c727a0e95f02b67859d42cc38"
    SIGN = "签名"
    ding = DingtalkRobot(URL, SIGN)
    print(ding.send_text("Hello World"))
    
    print(timestamp)
    print(sign)

#headers = {'Content-Type': 'application/json;charset=utf-8'}
#api_url = "https://oapi.dingtalk.com/robot/send?access_token=4465f5ab0da41e48d962df155450a22f70f63a6c727a0e95f02b67859d42cc38"
#def msg(text):
#    json_text = {
#     "msgtype": "text",
#     "text": {
#        "content":"[koal_admin]:"+text
#   },
#    "at": {
#       "atMobiles": [
#           "18721967723" #需要@who？
#        ],
#        "isAtALL": False
#      }
#
#    }
#    print requests.post(api_url,json.dumps(json_text),headers=headers).content
#
#if __name__ == '__main__':
#   text = sys.argv[1]
#   msg(text)
