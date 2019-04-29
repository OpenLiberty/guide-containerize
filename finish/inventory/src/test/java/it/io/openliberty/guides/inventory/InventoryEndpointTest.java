// tag::copyright[]
/*******************************************************************************
 * Copyright (c) 2018, 2019 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - Initial implementation
 *******************************************************************************/
// end::copyright[]
package it.io.openliberty.guides.inventory;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLSession;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.core.Response;
import javax.json.JsonObject;
import javax.ws.rs.core.MediaType;

import org.apache.cxf.jaxrs.provider.jsrjsonp.JsrJsonpProvider;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class InventoryEndpointTest {

    private static String invUrl;
    private static String sysUrl;
    private static String systemServiceIp;

    private Client client;
    private Response response;

    @BeforeClass
    public static void oneTimeSetup() {
        String invServPort = System.getProperty("inventory.http.port");
        String sysServPort = System.getProperty("system.http.port");
        String sysIp = System.getProperty("system.ip");
        
        systemServiceIp = System.getProperty("system.ip");
        
        invUrl = "http://localhost" + ":" + invServPort + "/inventory/systems/";
        sysUrl = "http://localhost" + ":" + sysServPort + "/system/properties/";
    }

    @Before
    public void setup() {
        response = null;
        client = ClientBuilder.newBuilder()
                    .hostnameVerifier(new HostnameVerifier() {
                        public boolean verify(String hostname, SSLSession session) {
                            return true;
                        }
                    })
                    .build();

        client.register(JsrJsonpProvider.class);
        client.target(invUrl + "reset").request().post(null);
    }

    @After
    public void teardown() {
        client.close();
    }

    @Test
    public void testSuite() {
        this.testEmptyInventory();
        this.testHostRegistration();
        this.testSystemPropertiesMatch();
        this.testUnknownHost();
    }

    public void testEmptyInventory() {
        Response response = this.getResponse(invUrl);
        this.assertResponse(invUrl, response);

        JsonObject obj = response.readEntity(JsonObject.class);

        int expected = 0;
        int actual = obj.getInt("total");
        assertEquals("The inventory should be empty on application start but it wasn't",
                    expected, actual);

        response.close();
    }

    public void testHostRegistration() {
        this.visitSystemService();

        Response response = this.getResponse(invUrl);
        this.assertResponse(invUrl, response);

        JsonObject obj = response.readEntity(JsonObject.class);

        int expected = 1;
        int actual = obj.getInt("total");
        assertEquals("The inventory should have one entry for the system service:" + systemServiceIp, expected,
                    actual);

        boolean serviceExists = obj.getJsonArray("systems").getJsonObject(0)
                                    .get("hostname").toString()
                                    .contains(systemServiceIp);
        assertTrue("A host was registered, but it was not " + systemServiceIp,
                serviceExists);

        response.close();
    }

    public void testSystemPropertiesMatch() {
        Response invResponse = this.getResponse(invUrl);
        Response sysResponse = this.getResponse(sysUrl);

        this.assertResponse(invUrl, invResponse);
        this.assertResponse(sysUrl, sysResponse);

        JsonObject jsonFromInventory = (JsonObject) invResponse.readEntity(JsonObject.class)
                                                            .getJsonArray("systems")
                                                            .getJsonObject(0)
                                                            .get("properties");

        JsonObject jsonFromSystem = sysResponse.readEntity(JsonObject.class);

        String osNameFromInventory = jsonFromInventory.getString("os.name");
        String osNameFromSystem = jsonFromSystem.getString("os.name");
        this.assertProperty("os.name", systemServiceIp, osNameFromSystem,
                            osNameFromInventory);

        String userNameFromInventory = jsonFromInventory.getString("user.name");
        String userNameFromSystem = jsonFromSystem.getString("user.name");
        this.assertProperty("user.name", systemServiceIp, userNameFromSystem,
                            userNameFromInventory);

        invResponse.close();
        sysResponse.close();
    }

    public void testUnknownHost() {
        Response response = this.getResponse(invUrl);
        this.assertResponse(invUrl, response);

        Response badResponse = client.target(invUrl + "badhostname")
            .request(MediaType.APPLICATION_JSON)
            .get();

        String obj = badResponse.readEntity(String.class);

        boolean isError = obj.contains("ERROR");
        assertTrue("badhostname is not a valid host but it didn't raise an error",
                isError);

        response.close();
        badResponse.close();
    }

    // Returns response information from the specified URL.
    private Response getResponse(String url) {
        return client.target(url).request().get();
    }

    // Asserts that the given URL has the correct response code of 200.
    private void assertResponse(String url, Response response) {
        // System.out.println("THE URL :" + url + " GIVES THE RESPONSE CODE: " + response.getStatus());
        assertEquals("Incorrect response code from " + url, 200,
                    response.getStatus());
    }

    // Asserts that the specified JVM system property is equivalent in both the
    // system and inventory services.
    private void assertProperty(String propertyName, String hostname,
        String expected, String actual) {
        assertEquals("JVM system property [" + propertyName + "] "
            + "in the system service does not match the one stored in "
            + "the inventory service for " + hostname, expected, actual);
    }

    //Makes a simple GET request to inventory/localhost.
    private void visitSystemService() {
        Response response = this.getResponse(sysUrl);
        this.assertResponse(sysUrl, response);
        response.close();

        Response targetResponse = client
            .target(invUrl + systemServiceIp)
            .request()
            .get();

        targetResponse.close();
    }

}
