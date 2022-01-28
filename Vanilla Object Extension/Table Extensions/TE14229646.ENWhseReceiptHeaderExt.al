tableextension 14229646 "EN Whse Receipt Header Ext" extends "Warehouse Receipt Header"
{
    fields
    {
        field(14229700; "Name ELA"; Text[50])
        {
            Caption = 'Name';
        }
        field(14229701; "Address ELA"; Text[50])
        {
            Caption = 'Address';
        }
        field(14229702; "Address 2 ELA"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(14229703; "City ELA"; Text[30])
        {
            Caption = 'City';
        }

        field(14229704; "County ELA"; Text[30])
        {
            Caption = 'County';
        }
        field(14229705; "Post Code ELA"; Text[20])
        {
            Caption = 'Post Code';
        }
        field(14229706; "Country/Region Code ELA"; Text[10])
        {
            Caption = 'Country/Region Code';
        }
        field(14229707; "Contact ELA"; Text[50])
        {
            Caption = 'Contact';
        }
        field(51000; "No. Pallets"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Shipping Agent Code ELA"; Code[10])
        {
            TableRelation = "Shipping Agent";
            DataClassification = ToBeClassified;
        }
        field(51003; "Exp. Delivery Appointment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(51004; "Exp. Delivery Appointment Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(51005; "Act. Delivery Appointment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(51006; "Act. Delivery Appointment Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
		field(14229200; "Source Doc. No. ELA"; Code[10])
        {
            Caption = 'Source Doc. No.';
            DataClassification = ToBeClassified;
        }

        field(14229201; "Off-load Status ELA"; Option)
        {
            OptionMembers = "Pending","Started","Completed";
            Caption = 'Off-load Status';
            DataClassification = ToBeClassified;
        }

    }
	trigger OnDelete()
    var
        Container: record "Container ELA";
        Repor: Report 5753;
    begin
        Container.reset;
        container.SetRange(Completed, false);
        // Container.SetRange("Whse. Document Type", Container."Whse. Document Type"::Receipt);
        //Container.SetRange("Whse. Document No.", "No.");
        if Container.FindSet() then
            repeat
                Container.Delete(true);
            until Container.Next() = 0;
    end;
}
