table 14229821 "Fin. WO Resource ELA"
{
    DrillDownPageID = "Fin. WO Resources";
    LookupPageID = "Fin. WO Resources";

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = "Finished WO Header ELA"."PM Work Order No.";
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header ELA"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header ELA".Code;
        }
        field(10; Type; Option)
        {
            OptionMembers = Equipment,"Fixed Asset",Resource;
        }
        field(11; "No."; Code[20])
        {
            // TableRelation = IF (Type = CONST (Equipment)) Table23019207.Field1
            // ELSE
            // IF (Type = CONST ("Fixed Asset")) "Fixed Asset"."No."
            // ELSE
            // IF (Type = CONST (Resource)) Resource."No.";

            trigger OnValidate()
            begin
                case Type of
                    //Type::Equipment:
                        // begin
                        //     grecPMWOResource.GET("No.");
                        //     Description := grecPMWOResource.Description;
                        // end;
                    Type::"Fixed Asset":
                        begin
                            grecFixedAsset.Get("No.");
                            Description := grecFixedAsset.Description;
                        end;
                    Type::Resource:
                        begin
                            grecResource.Get("No.");
                            Description := grecResource.Name;
                        end;
                end;
            end;
        }
        field(12; Description; Text[50])
        {
        }
        field(20; Quantity; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(21; "Unit of Measure"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(22; "Work Type Code"; Code[10])
        {
            TableRelation = "Work Type";
        }
        field(25; "Unit Cost"; Decimal)
        {
            DecimalPlaces = 2 : 5;
        }
        field(26; "Total Cost"; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "PM Work Order No.", "PM WO Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        //grecPMWOResource: Record Table23019207;
        grecFixedAsset: Record "Fixed Asset";
        grecResource: Record Resource;
}

