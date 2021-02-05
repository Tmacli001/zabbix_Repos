#!/usr/bin/python3
#-*- coding: utf-8 -*-
#import json,requests,sys,os

import json,sys,os,time,hmac,hashlib,base64,urllib.parse
timestamp = str(round(time,time() * 1000))
secret = 'SECdb6372c3ab19eb777bd35bc4ff5c235376b81bfda39537adc5dbfb9cd21f29a5'
secret_enc = secret.encode('utf-8')
string_to_sign = '{}\n{}'.format(timestamp,secret)
string_to_sign_enc = string_to_sign.encode('utf-8')
hmac_code = hmac.new(secret_enc, string_to_sign_enc, digestmod=hashlib.sha256).digest()
sign = urllib.parse.quote_plus(base64.b64encode(hmac_code))
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




