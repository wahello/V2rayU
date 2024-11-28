//
//  V2raySubscription.swift
//  V2rayU
//
//  Created by yanue on 2019/5/15.
//  Copyright © 2019 yanue. All rights reserved.
//

import Cocoa

/**
 - {"type":"ss","name":"v2rayse_test_1","server":"198.57.27.218","port":5004,"cipher":"aes-256-gcm","password":"g5MeD6Ft3CWlJId"}
 - {"type":"ssr","name":"v2rayse_test_3","server":"20.239.49.44","port":59814,"protocol":"origin","cipher":"dummy","obfs":"plain","password":"3df57276-03ef-45cf-bdd4-4edb6dfaa0ef"}
 - {"type":"vmess","name":"v2rayse_test_2","ws-opts":{"path":"/"},"server":"154.23.190.162","port":443,"uuid":"b9984674-f771-4e67-a198-","alterId":"0","cipher":"auto","network":"ws"}
 - {"type":"vless","name":"test","server":"1.2.3.4","port":7777,"uuid":"abc-def-ghi-fge-zsx","skip-cert-verify":true,"network":"tcp","tls":true,"udp":true}
 - {"type":"trojan","name":"v2rayse_test_4","server":"ca-trojan.bonds.id","port":443,"password":"bc7593fe-0604-4fbe--b4ab-11eb-b65e-1239d0255272","udp":true,"skip-cert-verify":true}
 - {"type":"http","name":"http_proxy","server":"124.15.12.24","port":251,"username":"username","password":"password","udp":true}
 - {"type":"socks5","name":"socks5_proxy","server":"124.15.12.24","port":2312,"udp":true}
 - {"type":"socks5","name":"telegram_proxy","server":"1.2.3.4","port":123,"username":"username","password":"password","udp":true}
 */
/**
 CREATE TABLE "ProfileItem" (
   "indexId"  varchar NOT NULL,
   "configType"  integer,
   "configVersion"  integer,
   "address"  varchar,
   "port"  integer,
   "id"  varchar,
   "alterId"  integer,
   "security"  varchar,
   "network"  varchar,
   "remarks"  varchar,
   "headerType"  varchar,
   "requestHost"  varchar,
   "path"  varchar,
   "streamSecurity"  varchar,
   "allowInsecure"  varchar,
   "subid"  varchar,
   "isSub"  integer,
   "flow"  varchar,
   "sni"  varchar,
   "alpn"  varchar,
   "coreType"  integer,
   "preSocksPort"  integer,
   "fingerprint"  varchar,
   "displayLog"  integer,
   "publicKey"  varchar,
   "shortId"  varchar,
   "spiderX"  varchar,
   PRIMARY KEY("indexId")
 );
 */
import SwiftUI

class ProxyModel: ObservableObject, Identifiable {
    // 公共属性
    @Published var `protocol`: V2rayProtocolOutbound
    @Published var network: V2rayStreamNetwork = .tcp
    @Published var streamSecurity: V2rayStreamSecurity = .none
    @Published var subid: String
    @Published var address: String
    @Published var port: Int
    @Published var id: String
    @Published var alterId: Int
    @Published var security: String
    @Published var remark: String
    @Published var headerType: V2rayHeaderType = .none
    @Published var requestHost: String
    @Published var path: String
    @Published var allowInsecure: Bool = true
    @Published var flow: String = ""
    @Published var sni: String = ""
    @Published var alpn: V2rayStreamAlpn = .h2h1
    @Published var fingerprint: V2rayStreamFingerprint = .chrome
    @Published var publicKey: String = ""
    @Published var shortId: String = ""
    @Published var spiderX: String = ""

    // server
    private(set) var serverVmess = V2rayOutboundVMessItem()
    private(set) var serverSocks5 = V2rayOutboundSockServer()
    private(set) var serverShadowsocks = V2rayOutboundShadowsockServer()
    private(set) var serverVless = V2rayOutboundVLessItem()
    private(set) var serverTrojan = V2rayOutboundTrojanServer()

    // stream settings
    private(set) var streamTcp = TcpSettings()
    private(set) var streamKcp = KcpSettings()
    private(set) var streamDs = DsSettings()
    private(set) var streamWs = WsSettings()
    private(set) var streamH2 = HttpSettings()
    private(set) var streamQuic = QuicSettings()
    private(set) var streamGrpc = GrpcSettings()

    // security settings
    private(set) var securityTls = TlsSettings() // tls|xtls
    private(set) var securityReality = RealitySettings() // reality
    
    // outbound
    private(set) var outbound = V2rayOutbound()

    // 对应编码的 `CodingKeys` 枚举
    enum CodingKeys: String, CodingKey {
        case `protocol`, subid, address, port, id, alterId, security, network, remark,
             headerType, requestHost, path, streamSecurity, allowInsecure, flow, sni, alpn, fingerprint, publicKey, shortId, spiderX
    }

    // 提供默认值的初始化器
    init(
        protocol: V2rayProtocolOutbound,
        address: String,
        port: Int,
        id: String,
        alterId: Int = 0,
        security: String,
        network: V2rayStreamNetwork = .tcp,
        remark: String,
        headerType: V2rayHeaderType = .none,
        requestHost: String = "",
        path: String = "",
        streamSecurity: V2rayStreamSecurity = .none,
        allowInsecure: Bool = true,
        subid: String = "",
        flow: String = "",
        sni: String = "",
        alpn: V2rayStreamAlpn = .h2h1,
        fingerprint: V2rayStreamFingerprint = .chrome,
        publicKey: String = "",
        shortId: String = "",
        spiderX: String = ""
    ) {
        self.protocol = `protocol` // Initialize protocol
        self.address = address // Initialize address
        self.port = port // Initialize port
        self.id = id // Initialize id
        self.alterId = alterId // Initialize alterId
        self.security = security // Initialize security
        self.network = network // Initialize network
        self.remark = remark // Initialize remark
        self.headerType = headerType // Initialize headerType
        self.requestHost = requestHost // Initialize requestHost
        self.path = path // Initialize path
        self.streamSecurity = streamSecurity // Initialize streamSecurity
        self.allowInsecure = allowInsecure // Initialize allowInsecure
        self.subid = subid // Initialize subid
        self.flow = flow // Initialize flow
        self.sni = sni // Initialize sni
        self.alpn = alpn // Initialize alpn
        self.fingerprint = fingerprint // Initialize fingerprint
        self.publicKey = publicKey // Initialize publicKey
        self.shortId = shortId // Initialize shortId
        self.spiderX = spiderX // Initialize spiderX
        // 初始化时调用更新方法
        updateServerSettings()
        updateStreamSettings()
    }

    // 更新 server 配置
    private func updateServerSettings() {
        switch `protocol` {
        case .vmess:
            // user
            var user = V2rayOutboundVMessUser()
            user.id = self.id
            user.alterId = Int(self.alterId)
            user.security = self.security
            // vmess
            serverVmess = V2rayOutboundVMessItem()
            serverVmess.address = self.address
            serverVmess.port = self.port
            serverVmess.users = [user]
            var vmess = V2rayOutboundVMess()
            vmess.vnext = [serverVmess]
            outbound.settings = vmess
            
        case .vless:
            // user
            var user = V2rayOutboundVLessUser()
            user.id = self.id
            user.flow = self.flow
            user.encryption = self.security
            // vless
            serverVless = V2rayOutboundVLessItem()
            serverVless.address = self.address
            serverVless.port = self.port
            serverVless.users = [user]
            var vless = V2rayOutboundVLess()
            vless.vnext = [serverVless]
            outbound.settings = vless

        case .shadowsocks:
            serverShadowsocks = V2rayOutboundShadowsockServer()
            serverShadowsocks.address = self.address
            serverShadowsocks.port = self.port
            serverShadowsocks.method = self.security
            serverShadowsocks.password = self.id
            var ss = V2rayOutboundShadowsocks()
            ss.servers = [serverShadowsocks]
            outbound.settings = ss

        case .socks:
            // user
            var user = V2rayOutboundSockUser()
            user.user = self.id
            user.pass = self.id
            // socks5
            serverSocks5 = V2rayOutboundSockServer()
            serverSocks5.address = self.address
            serverSocks5.port = self.port
            serverSocks5.users = [user]
            var socks = V2rayOutboundSocks()
            socks.servers = [serverSocks5]
            outbound.settings = socks
            
        case .trojan:
            serverTrojan = V2rayOutboundTrojanServer()
            serverTrojan.address = self.address
            serverTrojan.port = self.port
            serverTrojan.password = self.id
            serverTrojan.flow = self.flow
            var outboundTrojan = V2rayOutboundTrojan()
            outboundTrojan.servers = [serverTrojan]
            outbound.settings = outboundTrojan
            
        default:
            break
        }
    }
    
    private func updateStreamSettings() {
        var streamSettings = V2rayStreamSettings()
        streamSettings.network = self.network
        
        // 根据网络类型配置
        configureStreamSettings(network: self.network, settings: &streamSettings)
        
        // 根据安全设置配置
        configureSecuritySettings(security: self.streamSecurity, settings: &streamSettings)
        
        outbound.streamSettings = streamSettings
    }
    
    // 提取网络类型配置
    private func configureStreamSettings(network: V2rayStreamNetwork, settings: inout V2rayStreamSettings) {
        switch network {
        case .tcp:
            streamTcp.header.type = self.headerType.rawValue
            settings.tcpSettings = streamTcp
        case .kcp:
            streamKcp.header.type = self.headerType.rawValue
            settings.kcpSettings = streamKcp
        case .http, .h2:
            streamH2.path = self.path
            streamH2.host = [self.requestHost]
            settings.httpSettings = streamH2
        case .ws:
            streamWs.path = self.path
            streamWs.headers.host = self.requestHost
            settings.wsSettings = streamWs
        case .domainsocket:
            streamDs.path = self.path
            settings.dsSettings = streamDs
        case .quic:
            streamQuic.key = self.path
            settings.quicSettings = streamQuic
        case .grpc:
            streamGrpc.serviceName = self.path
            settings.grpcSettings = streamGrpc
        }
    }

    // 提取安全配置
    private func configureSecuritySettings(security: V2rayStreamSecurity, settings: inout V2rayStreamSettings) {
        settings.security = security
        switch security {
        case .tls, .xtls:
            securityTls = TlsSettings(
                serverName: sni,
                allowInsecure: allowInsecure,
                alpn: alpn.rawValue,
                fingerprint: fingerprint.rawValue
            )
            settings.tlsSettings = securityTls
        case .reality:
            securityReality = RealitySettings(
                fingerprint: fingerprint.rawValue,
                serverName: sni,
                shortId: shortId,
                spiderX: spiderX
            )
            settings.realitySettings = securityReality
        default:
            break
        }
    }

    func toJSON() -> String {
        updateServerSettings()
        updateStreamSettings()
        return outbound.toJSON()
    }
}
