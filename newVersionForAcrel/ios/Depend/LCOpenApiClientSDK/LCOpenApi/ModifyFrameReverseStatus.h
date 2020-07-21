/**
 *  Auto created by ApiCreator Tool.
 *  SVN Rev: unknown, Author: unknown, Date: unknown
 *  SHOULD NOT MODIFY!
 */
 
#ifndef _LC_OPENAPI_CLIENT_ModifyFrameReverseStatus_H_
#define _LC_OPENAPI_CLIENT_ModifyFrameReverseStatus_H_

#include "LCOpenApiDefine.h"
#include "LCOpenApiRequest.h"
#include "LCOpenApiResponse.h"

/** DESCRIPTION: 
设置图像翻转状态

 */

namespace Dahua{
namespace LCOpenApi{
	using namespace std;
	class ModifyFrameReverseStatusRequest : public LCOpenApiRequest
	{
	public:
		class ModifyFrameReverseStatusRequestData
		{
		public:
			ModifyFrameReverseStatusRequestData();
			~ModifyFrameReverseStatusRequestData();
			
		public:
			/** normal或reverse */
			string direction;
		public:
			/** [cstr]modifyFrameReverseStatus */
			#define _STATIC_ModifyFrameReverseStatusRequestData_method "modifyFrameReverseStatus"
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
		ModifyFrameReverseStatusRequest();
		~ModifyFrameReverseStatusRequest();
	public:
		virtual int build();
	public:
		ModifyFrameReverseStatusRequestData data;
	};

	
	typedef typename ModifyFrameReverseStatusRequest::ModifyFrameReverseStatusRequestData ModifyFrameReverseStatusRequestData;


	class ModifyFrameReverseStatusResponse : public LCOpenApiResponse
	{
	public:
		class ModifyFrameReverseStatusResponseData
		{
		public:
			ModifyFrameReverseStatusResponseData();
			~ModifyFrameReverseStatusResponseData();
			
		public:
			/** [int][O]保留 */
			int _nouse;

		};
	public:
		ModifyFrameReverseStatusResponse();
		~ModifyFrameReverseStatusResponse();
	public:
		virtual int parse();
	public:
		ModifyFrameReverseStatusResponseData data;
	};

	
	typedef typename ModifyFrameReverseStatusResponse::ModifyFrameReverseStatusResponseData ModifyFrameReverseStatusResponseData;

}
}

#endif
