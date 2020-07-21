/**
 *  Auto created by ApiCreator Tool.
 *  SVN Rev: unknown, Author: unknown, Date: unknown
 *  SHOULD NOT MODIFY!
 */
 
#ifndef _LC_OPENAPI_CLIENT_RecoverSDCard_H_
#define _LC_OPENAPI_CLIENT_RecoverSDCard_H_

#include "LCOpenApiDefine.h"
#include "LCOpenApiRequest.h"
#include "LCOpenApiResponse.h"

/** DESCRIPTION: 
请求初始化SD卡

 */

namespace Dahua{
namespace LCOpenApi{
	using namespace std;
	class RecoverSDCardRequest : public LCOpenApiRequest
	{
	public:
		class RecoverSDCardRequestData
		{
		public:
			RecoverSDCardRequestData();
			~RecoverSDCardRequestData();
			
		public:
			/** [cstr]recoverSDCard */
			#define _STATIC_RecoverSDCardRequestData_method "recoverSDCard"
			string method;
		public:
			/** 通道ID */
			string channelId;
		public:
			/** 授权token(userToken或accessToken) */
			string token;
		public:
			/** 设备ID */
			string deviceId;

		};
	public:
		RecoverSDCardRequest();
		~RecoverSDCardRequest();
	public:
		virtual int build();
	public:
		RecoverSDCardRequestData data;
	};

	
	typedef typename RecoverSDCardRequest::RecoverSDCardRequestData RecoverSDCardRequestData;


	class RecoverSDCardResponse : public LCOpenApiResponse
	{
	public:
		class RecoverSDCardResponseData
		{
		public:
			RecoverSDCardResponseData();
			~RecoverSDCardResponseData();
			
		public:
			/** 结果 */
			string result;

		};
	public:
		RecoverSDCardResponse();
		~RecoverSDCardResponse();
	public:
		virtual int parse();
	public:
		RecoverSDCardResponseData data;
	};

	
	typedef typename RecoverSDCardResponse::RecoverSDCardResponseData RecoverSDCardResponseData;

}
}

#endif
