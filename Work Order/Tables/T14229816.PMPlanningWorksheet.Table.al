table 14229816 "PM Planning Worksheet ELA"
{
    Caption = 'PM Planning Worksheet';
    DrillDownPageID = 23019267;
    LookupPageID = 23019267;

    fields
    {
        field(1; "Worksheet Batch Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "PM Worksheet Batch ELA";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header ELA".Code;

            trigger OnValidate()
            begin
                SetDefaults;
            end;
        }
        field(4; "Version No."; Code[10])
        {
            Description = 'Editable=No';
            TableRelation = "PM Procedure Header ELA"."Version No." WHERE (Code = FIELD (Description));

            trigger OnValidate()
            begin
                SetDefaults;
            end;
        }
        field(5; Description; Text[80])
        {
        }
        field(10; "Person Responsible"; Code[20])
        {
            TableRelation = Employee;
        }
        field(11; "PM Group Code"; Code[10])
        {
            TableRelation = "PM Group ELA";
        }
        field(13; "Work Order Freq."; DateFormula)
        {
        }
        field(20; Type; Option)
        {
            OptionCaption = ' ,Machine Center,Work Center,Fixed Asset';
            OptionMembers = " ","Machine Center","Work Center","Fixed Asset";

            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    Validate("No.", '');
            end;
        }
        field(31; "PM Work Order No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(40; "PM Scheduling Type"; Option)
        {
            OptionCaption = 'Calendar,Cycles,Qty. Produced,Run Time,Stop Time';
            OptionMembers = Calendar,Cycles,"Qty. Produced","Run Time","Stop Time";

            trigger OnValidate()
            begin
                if ("PM Scheduling Type" = "PM Scheduling Type"::"Qty. Produced") or
                   ("PM Scheduling Type" = "PM Scheduling Type"::"Run Time") or
                   ("PM Scheduling Type" = "PM Scheduling Type"::"Stop Time")
                then
                    if not ((Type = Type::"Machine Center") or
                       (Type = Type::"Work Center")) then
                        FieldError(Type);
            end;
        }
        field(41; "Evaluation Qty."; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(42; "Schedule at %"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            InitValue = 100;
            MaxValue = 100;
            MinValue = 0;
        }
        field(45; "Maintenance Time"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(46; "Maintenance UOM"; Code[10])
        {
            TableRelation = "Capacity Unit of Measure";
        }
        field(100; "Work Order Date"; Date)
        {
        }
        field(101; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST ("Machine Center")) "Machine Center"
            ELSE
            IF (Type = CONST ("Work Center")) "Work Center"
            ELSE
            IF (Type = CONST ("Fixed Asset")) "Fixed Asset";

            trigger OnValidate()
            begin
                if "No." <> '' then begin
                    case Type of
                        Type::"Machine Center":
                            begin
                                grecMachCenter.Get("No.");

                                "Serial No." := grecMachCenter."Serial No.";
                                Name := grecMachCenter.Name;
                            end;
                        Type::"Work Center":
                            begin
                                grecWorkCenter.Get("No.");

                                "Serial No." := grecWorkCenter."Serial No.";
                                Name := grecWorkCenter.Name;
                            end;
                        Type::"Fixed Asset":
                            begin
                                grecFA.Get("No.");

                                "Serial No." := grecFA."Serial No.";
                                Name := grecFA.Description;
                            end;
                    end;
                end else begin
                    Clear("Serial No.");
                    Clear(Name);
                end;
            end;
        }
        field(102; "Serial No."; Text[30])
        {
            Editable = false;
        }
        field(103; Name; Text[50])
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Worksheet Batch Name", "Line No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
        }
    }

    fieldgroups
    {
    }

    var
        grecPMWkshtBatch: Record "PM Worksheet Batch ELA";
        grecPMWkshtLine: Record "PM Planning Worksheet ELA";
        grecPMProcedure: Record "PM Procedure Header ELA";
        grecFA: Record "Fixed Asset";
        grecMachCenter: Record "Machine Center";
        grecWorkCenter: Record "Work Center";
        gcduPMMgt: Codeunit "PM Management ELA";

    [Scope('Internal')]
    procedure SetUpNewLine(LastItemJnlLine: Record "Item Journal Line")
    var
        lrecLastPMWkshtLine: Record "PM Planning Worksheet ELA";
    begin

        grecPMWkshtBatch.Get("Worksheet Batch Name");
        grecPMWkshtLine.SetRange("Worksheet Batch Name", "Worksheet Batch Name");
        if grecPMWkshtLine.Find('-') then begin
            //  "Audit Date" := LastgrecPMWkshtLine."Audit Date";
        end else begin
            //  "Audit Date" := WORKDATE;
        end;
    end;

    [Scope('Internal')]
    procedure SetDefaults()
    var
        lcodVersionNo: Code[20];
    begin
        if "Version No." = '' then
            "Version No." := gcduPMMgt.GetActiveVersion("PM Procedure Code");

        grecPMProcedure.Get("PM Procedure Code", "Version No.");

        Type := grecPMProcedure.Type;
        Validate("No.", grecPMProcedure."No.");
        "Person Responsible" := grecPMProcedure."Person Responsible";
        "PM Group Code" := grecPMProcedure."PM Group Code";
        "PM Work Order No. Series" := grecPMProcedure."PM Work Order No. Series";
        Description := grecPMProcedure.Description;
        "PM Scheduling Type" := grecPMProcedure."PM Scheduling Type";
        "Evaluation Qty." := grecPMProcedure."Evaluation Qty.";
        "Schedule at %" := grecPMProcedure."Schedule at %";
        "Maintenance Time" := grecPMProcedure."Maintenance Time";
        "Maintenance UOM" := grecPMProcedure."Maintenance UOM";
    end;
}

