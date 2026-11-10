public with sharing class AlohaAgentIdentityProbe {
    public class Request {
        @InvocableVariable(required=true)
        public Boolean requested;
    }

    public class Result {
        @InvocableVariable
        public Boolean completed;
    }

    @InvocableMethod(label='Aloha Identity Probe')
    public static List<Result> run(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request request : requests) {
            Result result = new Result();
            result.completed = request != null && request.requested == true;
            if (result.completed) {
                System.debug(LoggingLevel.WARN, 'ALOHA_IDENTITY_PROBE_P1_82F7C4 principal=' + UserInfo.getUserId());
            }
            results.add(result);
        }
        return results;
    }
}
