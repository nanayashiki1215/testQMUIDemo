/**
 *  Auto created by ApiCreator Tool.
 *  SVN Rev: unknown, Author: unknown, Date: unknown
 *  SHOULD NOT MODIFY!
 */
 
#ifndef _LC_OPENAPI_CLIENT_FrameReverseStatus_H_
#define _LC_OPENAPI_CLIENT_FrameReverseStatus_H_

#include "LCOpenApiDefine.h"
#include "LCOpenApiRequest.h"
#include "LCOpenApiResponse.h"

/** DESCRIPTION: 
获取图像翻转状态

 */

namespace Dahua{
namespace LCOpenApi{
	using namespace std;
	class FrameReverseStatusRequest : public LCOpenApiRequest
	{
	public:
		class FrameReverseStatusRequestData
		{
		public:
			FrameReverseStatusRequestData();
			~FrameReverseStatusRequestData();
			
		public:
			/** 授权token(userToken或accessToken) */
			string token;
		public:
			/** 通道ID */
			string channelId;
		public:
			/** [cstr]frameReverseStatus */
			#define _STATIC_FrameReverseStatusRequestData_method "frameReverseStatus"
			string method;
		public:
			/** 设备ID */
			string deviceId;

		};
	public:
		FrameReverseStatusRequest();
		~FrameReverseStatusRequest();
	public:
		virtual int build();
	public:
		FrameReverseStatusRequestData data;
	};

	
	typedef typename FrameReverseStatusRequest::FrameReverseStatusRequestData FrameReverseStatusRequestData;


	class FrameReverseStatusResponse : public LCOpenApiResponse
	{
	public:
		class FrameReverseStatusResponseData
		{
		public:
			FrameReverseStatusResponseData();
			~FrameReverseStatusResponseData();
			
		public:
			/** normal或reverse */
			string direction;

		};
	public:
		FrameReverseStatusResponse();
		~FrameReverseStatusResponse();
	public:
		virtual int parse();
	public:
		FrameReverseStatusResponseData data;
	};

	
	typedef typename FrameReverseStatusResponse::FrameReverseStatusResponseData FrameReverseStatusResponseData;

}
}

#endif
