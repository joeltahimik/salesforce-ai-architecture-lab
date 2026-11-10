@IsTest
private class AlohaAgentIdentityProbeTest {
    @IsTest
    static void returnsOnlyCompletionInInputOrder() {
        AlohaAgentIdentityProbe.Request requested = new AlohaAgentIdentityProbe.Request();
        requested.requested = true;
        AlohaAgentIdentityProbe.Request skipped = new AlohaAgentIdentityProbe.Request();
        skipped.requested = false;

        List<AlohaAgentIdentityProbe.Request> requests = new List<AlohaAgentIdentityProbe.Request>();
        requests.add(requested);
        requests.add(skipped);
        requests.add(null);

        Test.startTest();
        List<AlohaAgentIdentityProbe.Result> results = AlohaAgentIdentityProbe.run(requests);
        Assert.areEqual(0, Limits.getQueries());
        Assert.areEqual(0, Limits.getDmlStatements());
        Assert.areEqual(0, Limits.getCallouts());
        Test.stopTest();

        Assert.areEqual(3, results.size());
        Assert.isTrue(results[0].completed);
        Assert.isFalse(results[1].completed);
        Assert.isFalse(results[2].completed);
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(results[0]));
        Assert.areEqual(1, payload.size());
        Assert.areEqual(true, payload.get('completed'));
    }
}
