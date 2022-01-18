table 23019254 "PM Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(2; "PM Procedure Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(3; "PM Work Order Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(10; "Notify User on Order Creation"; Boolean)
        {
        }
        field(15; "MRO Item Category"; Code[10])
        {
            TableRelation = "Item Category";
        }
        field(200; "PM Work Order Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = Table23019260;
        }
        field(201; "PM Work Order Type Filter"; Option)
        {
            FieldClass = FlowFilter;
            OptionCaption = ' ,Item,Machine Center,Work Center,Fixed Asset,Vendor,Customer';
            OptionMembers = " ",Item,"Machine Center","Work Center","Fixed Asset",Vendor,Customer;
        }
        field(202; "PM Work Order No. Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = IF ("PM Work Order Type Filter" = CONST (Item)) Item
            ELSE
            IF ("PM Work Order Type Filter" = CONST ("Machine Center")) "Machine Center"
            ELSE
            IF ("PM Work Order Type Filter" = CONST ("Work Center")) "Work Center"
            ELSE
            IF ("PM Work Order Type Filter" = CONST ("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("PM Work Order Type Filter" = CONST (Vendor)) Vendor
            ELSE
            IF ("PM Work Order Type Filter" = CONST (Customer)) Customer;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

