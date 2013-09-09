# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from ubuntuuitoolkit import emulators as uitk


class Panel(uitk.Toolbar):
    pass


class Browser(uitk.MainView):

    """
    An emulator class that makes it easy to interact with the webbrowser app.
    """

    def get_toolbar(self):
        # Overridden since the browser doesn’t use the MainView’s Toolbar.
        return self.select_single(Panel)

    def get_keyboard_rectangle(self):
        return self.select_single("KeyboardRectangle")

    def get_chrome(self):
        return self.select_single("Chrome")

    def get_address_bar(self):
        """Get the browsers address bar"""
        return self.select_single("AddressBar", objectName="addressBar")

    def get_address_bar_clear_button(self):
        textfield = self.get_address_bar_text_field()
        return textfield.get_children_by_type("AbstractButton")[0]

    def get_address_bar_action_button(self):
        textfield = self.get_address_bar_text_field()
        return textfield.select_single("QQuickMouseArea",
                                       objectName="actionButton")

    def get_back_button(self):
        return self.select_single("ActionItem", objectName="backButton")

    def get_forward_button(self):
        return self.select_single("ActionItem", objectName="forwardButton")

    def get_current_webview(self):
        webviews = self.select_many("UbuntuWebView")
        return webviews[self.currentIndex]

    def get_error_sheet(self):
        return self.select_single("ErrorSheet")

    def get_address_bar_text_field(self):
        return self.get_address_bar().get_children_by_type("TextField")[0]

    def get_address_bar_suggestions(self):
        return self.select_single("Suggestions")

    def get_address_bar_suggestions_listview(self):
        suggestions = self.get_address_bar_suggestions()
        return suggestions.get_children_by_type("QQuickListView")[0]

    def get_address_bar_suggestions_listview_entries(self):
        listview = self.get_address_bar_suggestions_listview()
        return listview.get_children()[0].get_children_by_type("Base")

    def get_activity_view(self):
        return self.select_single("ActivityView")

    def get_tabslist(self):
        return self.get_activity_view().select_single("TabsList")

    def get_tabslist_newtab_delegate(self):
        return self.get_tabslist().select_single("UbuntuShape",
                                                 objectName="newTabDelegate")

    def get_tabslist_view(self):
        return self.get_tabslist().select_single("QQuickListView")

    def get_tabslist_view_delegates(self):
        view = self.get_tabslist_view()
        return view.select_many("PageDelegate", objectName="openTabDelegate")