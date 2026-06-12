internal import Combine
import Foundation
import MultipeerConnectivity

final class ConnectivityService: NSObject, ObservableObject {

    enum ConnectionState {
        case idle, searching, connected
    }

    @Published var connectionState: ConnectionState = .idle
    @Published var peerFound = false

    private(set) var myCode: String
    private let serviceType = "heartsignal"
    private var peerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var targetPartnerCode: String?

    override init() {
        if let saved = UserDefaults.standard.string(forKey: "myCode") {
            myCode = saved
        } else {
            let code = String(format: "%06d", Int.random(in: 0...999999))
            UserDefaults.standard.set(code, forKey: "myCode")
            myCode = code
        }
        peerID = MCPeerID(displayName: myCode)
        super.init()
    }

    func startConnecting(isNearby: Bool, partnerCode: String?) {
        targetPartnerCode = isNearby ? nil : partnerCode
        peerFound = false
        connectionState = .searching

        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        self.session = session

        let advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        self.advertiser = advertiser

        let browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
    }

    func stopConnecting() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
        advertiser = nil
        browser = nil
        session = nil
        peerFound = false
        connectionState = .idle
    }
}

// MARK: - MCSessionDelegate
extension ConnectivityService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard state == .connected else { return }
        DispatchQueue.main.async { self.connectionState = .connected }
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer: MCPeerID) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName: String, fromPeer: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension ConnectivityService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            guard let session = self.session else { invitationHandler(false, nil); return }
            // Nearby mode: accept all. Code mode: only accept if inviter's code matches our partner code.
            let accept = self.targetPartnerCode == nil || peerID.displayName == self.targetPartnerCode
            invitationHandler(accept, accept ? session : nil)
        }
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
}

// MARK: - MCNearbyServiceBrowserDelegate
extension ConnectivityService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        DispatchQueue.main.async {
            guard let session = self.session else { return }
            // Code mode: only invite if peer's display name matches our partner code.
            if let target = self.targetPartnerCode {
                guard peerID.displayName == target else { return }
            }
            self.peerFound = true
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {}
}
