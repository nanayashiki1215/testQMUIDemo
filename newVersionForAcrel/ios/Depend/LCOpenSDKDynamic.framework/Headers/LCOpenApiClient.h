//
//  Client.h
//  LCOpenApiClient_C++
//
//  Created by mac318340418 on 17/1/6.
//  Copyright © 2017年 bzy. All rights reserved.
//

#ifndef Client_H
#define Client_H

#include "Infra/Guard.h"
#include "LCOpenApiRequest.h"
#include "LCOpenApiResponse.h"
#include <string>

using namespace std;
typedef void *LCOpenApiHandle;

namespace Dahua {
namespace LCOpenApi {

    enum  protocolType {HTTP = 0, HTTPS = 1};
    class MetaInfo;
    class LCOpenApiClient {
    public:
        typedef void (*LCOpenApiClientLogger)(int level, const char* str);

    public:
        LCOpenApiClient();
        ~LCOpenApiClient();

    public:
        static LCOpenApiClient* getInstance();
        static LCOpenApiHandle client_create(protocolType protocol, const char *host, int port);
        static void client_destroy(LCOpenApiHandle hc);
        int request(LCOpenApiHandle hc, LCOpenApiRequest* req, LCOpenApiResponse* resp, int timeout);
        string request_build(LCOpenApiRequest* p, void* obj, MetaInfo* mi, const string& isSys);
        int request_sign(LCOpenApiRequest* p, const string& appId, const string& appSecret, string& time);
        int response_parse(LCOpenApiResponse* p, void* obj, MetaInfo* mi);
        void set_logger(LCOpenApiClientLogger logger);

        void set_host_port(const string& host, int port);
        void set_protocol(protocolType  protocol);
        void set_client(const string& type, const string& mac);
        void set_os_version(const string& version);
        void set_sdk_version(const string& version);
        void set_api_versin(const string& version);
        void set_safe_code(const string& bundleId, const string& isSDK);
        void set_ca_path(const string& caPath);
        void set_uri_prefix(const string& prefix);
        void set_appId(const string& appId);
        void set_appSecret(const string& appSecret);
        
        /*网络切换时原长连接失效，可使用此接口快速恢复，而不必等心跳超时恢复*/
        void client_refresh_longLives();
        void client_clear_all();

        const string get_client_host();
        const protocolType get_protocol();
        const int get_client_port();
        const string get_client_type();
        const string get_client_mac();
        const string get_os_version();
        const string get_sdk_version();
        const string get_api_version();
        const string get_safe_code();
        const string get_ca_path();
        const string get_version();
        const string get_uri_prefix();
        const string get_appId();
        const string get_appSecret();
        const unsigned int get_serialNo();

    private:
        protocolType protocol;
        int          port;
        string       host;
        string       appId;
        string       appSecret;
        string       type;
        string       mac;
        string       os_version;
        string       sdk_version;
        string       api_version;
        string       safe_code;
        string       ca_path;
        string       version;
        string       uri_prefix;

        static unsigned int m_serialNo;
        static LCOpenApiClient* sm_instance;
        static Dahua::Infra::CMutex m_serialNoMutex;
        static Dahua::Infra::CMutex m_instanceMutex;
    };
}
}
#endif /* Client_H */
