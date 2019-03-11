
package com.jozews.chessumbrella;

import android.os.Bundle;

import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.*;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.google.android.gms.nearby.Nearby;
import com.google.android.gms.nearby.connection.*;

import java.util.ArrayList;
import java.util.HashMap;


class LifecycleManager extends ConnectionLifecycleCallback implements EventChannel.StreamHandler {

    MainActivity  activity;

    public LifecycleManager(MainActivity activity) {
        this.activity = activity;
    }

    private EventChannel.EventSink eventSink;

    @Override
    public void onConnectionInitiated(String idEndpoint, ConnectionInfo connectionInfo) {
        HashMap map = new HashMap();
        map.put("type", 0);
        map.put("id_endpoint", idEndpoint);
        map.put("name_endpoint", connectionInfo.getEndpointName());
        eventSink.success(map);
    }

    @Override
    public void onConnectionResult(String idEndpoint, ConnectionResolution connectionResolution) {
        HashMap map = new HashMap();
        map.put("type", 1);
        map.put("id_endpoint", idEndpoint);
        map.put("accepted", connectionResolution.getStatus().getStatusCode() == 0); // * NEEDS DEBUGGING
        eventSink.success(map);
    }

    @Override
    public void onDisconnected(String idEndpoint) {
        HashMap map = new HashMap();
        map.put("type", 2);
        map.put("id_endpoint", idEndpoint);
        eventSink.success(map);
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        activity.onListen(this, o);
    }

    @Override
    public void onCancel(Object o) {
        this.eventSink = null;
        activity.onCancel(this, o);
    }
}


class DiscoveryManager extends EndpointDiscoveryCallback implements EventChannel.StreamHandler {

    MainActivity  activity;

    public DiscoveryManager(MainActivity activity) {
        this.activity = activity;
    }

    private EventChannel.EventSink eventSink;

    @Override
    public void onEndpointFound(String idEndpoint, DiscoveredEndpointInfo discoveredEndpointInfo) {
        HashMap map = new HashMap();
        map.put("type", 0);
        map.put("id_endpoint", idEndpoint);
        map.put("name_endpoint", discoveredEndpointInfo.getEndpointName());
        eventSink.success(map);
    }

    @Override
    public void onEndpointLost(String idEndpoint) {
        HashMap map = new HashMap();
        map.put("type", 1);
        eventSink.success(map);
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        activity.onListen(this, o);
    }

    @Override
    public void onCancel(Object o) {
        this.eventSink = null;
        activity.onCancel(this, o);
    }
}


class PayloadManager extends PayloadCallback implements EventChannel.StreamHandler {

    MainActivity  activity;

    public PayloadManager(MainActivity activity) {
        this.activity = activity;
    }

    private EventChannel.EventSink eventSink;

    @Override
    public void onPayloadReceived(String idEndpoint, Payload payload) {
        HashMap map = new HashMap();
        map.put("type", 0);
        map.put("payload", payload);
        eventSink.success(map);
    }

    @Override
    public void onPayloadTransferUpdate(String idEndpoint, PayloadTransferUpdate payloadTransferUpdate) {
        HashMap map = new HashMap();
        map.put("type", 1);
        map.put("total_bytes", payloadTransferUpdate.getTotalBytes());
        map.put("total_bytes_transferred", payloadTransferUpdate.getBytesTransferred());
        map.put("status", payloadTransferUpdate.getStatus());
        eventSink.success(map);
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        activity.onListen(this, o);
    }

    @Override
    public void onCancel(Object o) {
        this.eventSink = null;
        activity.onCancel(this, o);
    }
}



public class MainActivity extends FlutterActivity {


    static String nameChannelAdvertising = "nearby-advertising";
    static String nameChannelDiscovering = "nearby-discovering";
    static String nameChannelConnection = "nearby-connection";
    static String nameChannelPayload = "nearby-payload";
    static String nameChannelSend = "nearby-send";

    static LifecycleManager handlerAdvertising;
    static DiscoveryManager handlerDiscovery;
    static LifecycleManager handlerConnection;
    static PayloadManager handlerPayload;

    static String name;
    static String idService;


    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        handlerAdvertising = new LifecycleManager(this);
        new EventChannel(getFlutterView(), nameChannelAdvertising).setStreamHandler(handlerAdvertising);
        handlerAdvertising = new LifecycleManager(this);

        handlerDiscovery = new DiscoveryManager(this);
        new EventChannel(getFlutterView(), nameChannelDiscovering).setStreamHandler(handlerDiscovery);
        handlerDiscovery = new DiscoveryManager(this);

        handlerConnection = new LifecycleManager(this);
        new EventChannel(getFlutterView(), nameChannelConnection).setStreamHandler(handlerDiscovery);

        handlerPayload = new PayloadManager(this);
        new EventChannel(getFlutterView(), nameChannelPayload).setStreamHandler(handlerDiscovery);

        new MethodChannel(getFlutterView(), nameChannelSend).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (call.method.equals("sendPayload")) {
                            ArrayList<Object> array = (ArrayList<Object>)call.arguments;
                            String idEndpoint = (String)array.get(0);
                            Payload payload = (Payload)array.get(1);
                            sendPayload(idEndpoint, payload);
                        }
                    }
                });
    }

    void onListen(EventChannel.StreamHandler handler, Object obj) {
        ArrayList<Object> array = (ArrayList<Object>)obj;
        if (handler.equals(handlerAdvertising)) {
            name = (String)array.get(0);
            idService = (String)array.get(1);
            startAdvertising();
        }
        if (handler.equals(handlerDiscovery)) {
            idService = (String)array.get(0);
            startDiscovery();
        }
        if (handler.equals(handlerConnection)) {
            String idEndpoint = (String)array.get(0);
            requestConnection(idEndpoint);
        }
        if (handler.equals(handlerPayload)) {
            String idEndpoint = (String)array.get(0);
            acceptConnection(idEndpoint);
        }
    }

    void onCancel(EventChannel.StreamHandler handler, Object o) {
        // nothing to see here
    }

    void startAdvertising() {
        AdvertisingOptions advertisingOptions = new AdvertisingOptions.Builder().setStrategy(Strategy.P2P_CLUSTER).build();
        Nearby.getConnectionsClient(this).startAdvertising(name, idService, handlerAdvertising, advertisingOptions);
    }

    void startDiscovery() {
        DiscoveryOptions discoveryOptions = new DiscoveryOptions.Builder().setStrategy(Strategy.P2P_CLUSTER).build();
        Nearby.getConnectionsClient(this).startDiscovery(idService, handlerDiscovery, discoveryOptions);
    }

    void requestConnection(String idEndpoint) {
        Nearby.getConnectionsClient(this).requestConnection(name, idEndpoint, handlerConnection);
    }

    void acceptConnection(String idEndpoint) {
        Nearby.getConnectionsClient(this).acceptConnection(idEndpoint, handlerPayload);
    }

    void sendPayload(String idEndpoint, Payload payload) {
        Nearby.getConnectionsClient(this).sendPayload(idEndpoint, payload);
    }
}
