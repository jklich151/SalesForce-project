public with sharing class authorize {

    public TransactionResponse transactionResponse;

    public string refId;

    public TransactionMessages messages;

    public class TransactionResponse {
        public string responseCode;
        public string authCode;
        public string avsResultCode;
        public string cvvResultCode;
        public string cavvResultCode;
        public string transId;
        public string refTransID;
        public string transHash;
        public string testRequest;
        public string accountNumber;
        public string accountType;
        public Message[] messages;
        public UserField[] userFields;
        public string transHashSha2;
        public integer SupplementalDataQualificationIndicator;
        public string networkTransId;
        public Error[] errors;
    }
    public class Message {
        public string code;
        public string description;
        public string text;
    }

    public class UserField {
        public string name;
        public string value;
    }

    public class TransactionMessages {
        public string resultCode;
        public Message[] message;
    }

    public class Error {
        public string errorCode;
        public string errorText;
    }
}
