/**
 *  Auto created by ApiCreator Tool.
 *  SVN Rev: unknown, Author: unknown, Date: unknown
 *  SHOULD NOT MODIFY!
 */
 
#ifndef _LC_OPENAPI_CLIENT_CheckDeviceBindOrNot_H_
#define _LC_OPENAPI_CLIENT_CheckDeviceBindOrNot_H_

#include "LCOpenApiDefine.h"
#include "LCOpenApiRequest.h"
#include "LCOpenApiResponse.h"

/** DESCRIPTION: 
检查设备是否已绑定

 */

namespace Dahua{
namespace LCOpenApi{
	using namespace std;
	class CheckDeviceBindOrNotRequest : public LCOpenApiRequest
	{
	public:
		class CheckDeviceBindOrNotRequestData
		{
		public:
			CheckDeviceBindOrNotRequestData();
			~CheckDeviceBindOrNotRequestData();
			
		public:
			/** 授权token(userToken或accessToken) */
			string token;
		public:
			/** [cstr]checkDeviceBindOrNot */
			#define _STATIC_CheckDeviceBindOrNotRequestData_method "checkDeviceBindOrNot"
			string method;
		public:
			/** 设备ID */
			string deviceId;

		};
	public:
		CheckDeviceBindOrNotRequest();
		~CheckDeviceBindOrNotRequest();
	public:
		virtual int build();
	public:
		CheckDeviceBindOrNotRequestData data;
	};

	
	typedef typename CheckDeviceBindOrNotRequest::CheckDeviceBindOrNotRequestData CheckDeviceBindOrNotRequestData;


	class CheckDeviceBindOrNotResponse : public LCOpenApiResponse
	{
	public:
		class CheckDeviceBindOrNotResponseData
		{
		public:
			CheckDeviceBindOrNotResponseData();
			~CheckDeviceBindOrNotResponseData();
			
		public:
			/** [bool]是否被绑定到某个账号 */
			bool isBind;
		public:
			/** [bool]是否属于自己这个账号 */
			bool isMine;

		};
	public:
		CheckDeviceBindOrNotResponse();
		~CheckDeviceBindOrNotResponse();
	public:
		virtual int parse();
	public:
		CheckDeviceBindOrNotResponseData data;
	};

	
	typedef typename CheckDeviceBindOrNotResponse::CheckDeviceBindOrNotResponseData CheckDeviceBindOrNotResponseData;

}
}

#endif
