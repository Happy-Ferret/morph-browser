/*
 * Copyright 2013 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtWebKit 3.1
import QtWebKit.experimental 1.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Extras.Browser 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Unity.Action 1.0 as UnityActions
import Ubuntu.UnityWebApps 0.1 as UnityWebApps
import "../actions" as Actions
import ".."

BrowserView {
    id: webapp

    currentWebview: webview

    property alias url: webview.url
    property string webappName: ""
    property string webappModelSearchPath: ""
    property var webappUrlPatterns: null

    actions: [
        Actions.Back {
            onTriggered: webview.goBack()
        },
        Actions.Forward {
            onTriggered: webview.goForward()
        },
        Actions.Reload {
            onTriggered: webview.reload()
        }
    ]

    Page {
        anchors.fill: parent

        WebViewImpl {
            id: webview

            currentWebview: webview
            toolbar: panel.panel

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: parent.height - osk.height

            experimental.preferences.developerExtrasEnabled: developerExtrasEnabled

            contextualActions: ActionList {
                Actions.CopyLink {
                    enabled: webview.contextualData.href.toString()
                    onTriggered: Clipboard.push([webview.contextualData.href])
                }
                Actions.CopyImage {
                    enabled: webview.contextualData.img.toString()
                    onTriggered: Clipboard.push([webview.contextualData.img])
                }
            }

            function navigationRequestedDelegate(request) {
                if (!request.isMainFrame) {
                    request.action = WebView.AcceptRequest
                    return
                }

                var action = WebView.AcceptRequest
                var url = request.url.toString()

                // The list of url patterns defined by the webapp takes precedence over command line
                if (isRunningAsANamedWebapp()) {
                    if (unityWebapps.model.exists(unityWebapps.name) &&
                        !unityWebapps.model.doesUrlMatchesWebapp(unityWebapps.name, url)) {
                        action = WebView.IgnoreRequest
                    }
                } else if (webappUrlPatterns && webappUrlPatterns.length !== 0) {
                    action = WebView.IgnoreRequest
                    for (var i = 0; i < webappUrlPatterns.length; ++i) {
                        var pattern = webappUrlPatterns[i]
                        if (url.match(pattern)) {
                            action = WebView.AcceptRequest
                            break
                        }
                    }
                }

                request.action = action
                if (action === WebView.IgnoreRequest) {
                    Qt.openUrlExternally(url)
                }
            }

            onNewTabRequested: Qt.openUrlExternally(url)

            // Small shim needed when running as a webapp to wire-up connections
            // with the webview (message received, etc…).
            // This is being called (and expected) internally by the webapps
            // component as a way to bind to a webview lookalike without
            // reaching out directly to its internals (see it as an interface).
            function getUnityWebappsProxies() {
                var eventHandlers = {
                    onAppRaised: function () {
                        if (webbrowserWindow) {
                            try {
                                webbrowserWindow.raise();
                            } catch (e) {
                                console.debug('Error while raising: ' + e);
                            }
                        }
                    }
                };
                return UnityWebAppsUtils.makeProxiesForQtWebViewBindee(webview, eventHandlers)
            }
        }

        ErrorSheet {
            anchors.fill: webview
            visible: webview.lastLoadRequestStatus == WebView.LoadFailedStatus
            url: webview.url
            onRefreshClicked: webview.reload()
        }
    }

    PanelLoader {
        id: panel

        currentWebview: webview
        chromeless: webapp.chromeless

        backForwardButtonsVisible: webapp.backForwardButtonsVisible
        activityButtonVisible: false
        addressBarVisible: webapp.addressBarVisible

        anchors {
            left: parent.left
            right: parent.right
            bottom: panel.opened ? osk.top : parent.bottom
        }
    }

    UnityWebApps.UnityWebApps {
        id: unityWebapps
        name: webappName
        bindee: webview
        actionsContext: actionManager.globalContext
        model: UnityWebApps.UnityWebappsAppModel { searchPath: webappModelSearchPath }
    }

    function isRunningAsANamedWebapp() {
        return webappName && typeof(webappName) === 'string' && webappName.length != 0
    }
}