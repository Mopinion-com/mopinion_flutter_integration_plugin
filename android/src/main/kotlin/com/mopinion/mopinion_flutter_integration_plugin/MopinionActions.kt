package com.mopinion.mopinion_flutter_integration_plugin

import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.ADD_META_DATA
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.INITIALISE_SDK
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.REMOVE_ALL_META_DATA
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.REMOVE_META_DATA
import com.mopinion.mopinion_flutter_integration_plugin.MopinionFlutterBridgeConstants.TRIGGER_EVENT

sealed interface MopinionActions {
    data object InitialiseSDK: MopinionActions
    data object TriggerEvent: MopinionActions
    data object AddMetaData: MopinionActions
    data object RemoveMetaData: MopinionActions
    data object RemoveAllMetaData: MopinionActions
    companion object {
        val map = hashMapOf(
            INITIALISE_SDK to InitialiseSDK,
            TRIGGER_EVENT to TriggerEvent,
            ADD_META_DATA to AddMetaData,
            REMOVE_META_DATA to RemoveMetaData,
            REMOVE_ALL_META_DATA to RemoveAllMetaData
        )
    }
}