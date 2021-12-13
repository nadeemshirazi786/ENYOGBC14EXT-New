tableextension 51004 ShippingAgentELA extends "Shipping Agent"
{
    fields
    {
        field(51000; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
            DataClassification = ToBeClassified;
        }
    }
}