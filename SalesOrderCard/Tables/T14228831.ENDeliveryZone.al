table 14228831 "Delivery Zone ELA"
{
    Caption = 'Delivery Zone Code';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Type"; Enum "Delivery Type ELA")
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Indentation"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    var
        gblnUsedInShipTo: Boolean;
        gblnUsedInCustomer: Boolean;
        gblnUsedInShippingSurcharge: Boolean;
        grecCustomer: Record Customer;
        grecShipTo: Record "Ship-to Address";
        // grecShippingSurcharge	Record	Shipping Surcharge	
        CheckZoneErr: Text[250];
        Text004: TextConst ENU = '%1\You cannot change the type.';
        Text005: TextConst ENU = 'This Delivery Zone is assigned to Customers.';
        Text006: TextConst ENU = 'This Delivery Zone is assigned to Customer Ship-To Addresses.';
        Text007: TextConst ENU = 'This Delivery Zone is assigned to Shipping Surcharges.';

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure CheckIfZoneUsed(pcodZoneChecked: Code[20]): Boolean
    begin
        gblnUsedInShipTo := FALSE;
        gblnUsedInCustomer := FALSE;
        gblnUsedInShippingSurcharge := FALSE;


        // grecCustomer.setcurrentkey("delivery zone code");
        //         grecCustomer.setrange("delivery zone code", pcodzonechecked);
        //         if grecCustomer.findfirst then
        //             gblnUsedInCustomer := true;

        //         grecshipto.setcurrentkey("delivery zone code");
        //         grecshipto.setrange("delivery zone code", pcodzonechecked);
        //         if grecshipto.findfirst then
        //             gblnUsedInshipto := true;

        //         grecshippingsurcharge.setcurrentkey("delivery zone code");
        //         grecshippingsurcharge.setrange("delivery zone code", pcodzonechecked);
        //         if grecshippingsurcharge.findfirst then
        //             gblnUsedInshippingsurcharge := true;



        IF gblnUsedInShipTo OR gblnUsedInCustomer OR gblnUsedInShippingSurcharge THEN BEGIN
            MakeCheckZoneErr;
            EXIT(TRUE);
        END ELSE
            EXIT(FALSE);
    end;

    procedure MakeCheckZoneErr()
    begin
        IF gblnUsedInCustomer THEN BEGIN
            CheckZoneErr := Text005;
        END ELSE
            IF gblnUsedInShipTo THEN BEGIN
                CheckZoneErr := Text006;
            END ELSE
                IF gblnUsedInShippingSurcharge THEN BEGIN
                    CheckZoneErr := Text007;
                END;
    end;

    procedure GetCheckZoneErr(): Text[250]
    begin
        EXIT(CheckZoneErr);
    end;
}