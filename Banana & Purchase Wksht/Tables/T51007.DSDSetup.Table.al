table 51007 "DSD Setup"
{
    fields
    {
        field(1; "Code"; Code[10])
        {
        }
        field(20; "Unassigned Location Code"; Code[10])
        {
            TableRelation = Location;

            trigger OnValidate()
            var
                lrecLocation: Record Location;
            begin
                lrecLocation.Get("Unassigned Location Code");
            end;
        }
        field(30; "Route Pick Report ID"; Integer)
        {
            BlankZero = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(40; "Item Pick Report ID"; Integer)
        {
            BlankZero = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(100; "Route Pack Reclass Jnl. Templ."; Code[10])
        {
            TableRelation = "Item Journal Template".Name WHERE(Type = CONST(Transfer));
        }
        field(110; "Route Pack Reclass Jnl. Batch"; Code[10])
        {
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Route Pack Reclass Jnl. Templ."));
        }
        field(200; "Auto-Refresh Pick Forms"; Boolean)
        {
        }
        field(210; deprecated5; Boolean)
        {
        }
        field(500; "Hide Wksht. Transfer Actions"; Boolean)
        {
            Description = 'JF01894AC';
        }
        field(600; deprecated2; Code[20])
        {
            Description = 'was routing no. filter; now in item journal batch';
            TableRelation = "Routing Header"."No." WHERE(Status = CONST(Certified));
        }
        field(700; "Match S. Line Rte. on Hdr. Chg"; Boolean)
        {
        }
        field(701; "Orders Use Template Route"; Boolean)
        {
            Caption = 'Orders Use Template Route';
        }
        field(10001; "Standard Delivery Mon"; Boolean)
        {
            Caption = 'Standard Delivery Mon';

            trigger OnValidate()
            begin
                if "Standard Delivery Mon" then begin
                    "Alt. Delivery Mon" := false;
                end;
            end;
        }
        field(10002; "Standard Delivery Tues"; Boolean)
        {
            Caption = 'Standard Delivery Tues';

            trigger OnValidate()
            begin
                if "Standard Delivery Tues" then begin
                    "Alt. Delivery Tues" := false;
                end;
            end;
        }
        field(10003; "Standard Delivery Weds"; Boolean)
        {
            Caption = 'Standard Delivery Weds';

            trigger OnValidate()
            begin
                if "Standard Delivery Weds" then begin
                    "Alt. Delivery Weds" := false;
                end;
            end;
        }
        field(10004; "Standard Delivery Thurs"; Boolean)
        {
            Caption = 'Standard Delivery Thurs';

            trigger OnValidate()
            begin
                if "Standard Delivery Thurs" then begin
                    "Alt. Delivery Thurs" := false;
                end;
            end;
        }
        field(10005; "Standard Delivery Fri"; Boolean)
        {
            Caption = 'Standard Delivery Fri';

            trigger OnValidate()
            begin
                if "Standard Delivery Fri" then begin
                    "Alt. Delivery Fri" := false;
                end;
            end;
        }
        field(10006; "Standard Delivery Sat"; Boolean)
        {
            Caption = 'Standard Delivery Sat';

            trigger OnValidate()
            begin
                if "Standard Delivery Sat" then begin
                    "Alt. Delivery Sat" := false;
                end;
            end;
        }
        field(10007; "Standard Delivery Sun"; Boolean)
        {
            Caption = 'Standard Delivery Sun';

            trigger OnValidate()
            begin
                if "Standard Delivery Sun" then begin
                    "Alt. Delivery Sun" := false;
                end;
            end;
        }
        field(10011; "Alt. Delivery Mon"; Boolean)
        {
            Caption = 'Alt. Delivery Mon';

            trigger OnValidate()
            begin
                if "Alt. Delivery Mon" then begin
                    "Standard Delivery Mon" := false;
                end;
            end;
        }
        field(10012; "Alt. Delivery Tues"; Boolean)
        {
            Caption = 'Alt. Delivery Tues';

            trigger OnValidate()
            begin
                if "Alt. Delivery Tues" then begin
                    "Standard Delivery Tues" := false;
                end;
            end;
        }
        field(10013; "Alt. Delivery Weds"; Boolean)
        {
            Caption = 'Alt. Delivery Weds';

            trigger OnValidate()
            begin
                if "Alt. Delivery Weds" then begin
                    "Standard Delivery Weds" := false;
                end;
            end;
        }
        field(10014; "Alt. Delivery Thurs"; Boolean)
        {
            Caption = 'Alt. Delivery Thurs';

            trigger OnValidate()
            begin
                if "Alt. Delivery Thurs" then begin
                    "Standard Delivery Thurs" := false;
                end;
            end;
        }
        field(10015; "Alt. Delivery Fri"; Boolean)
        {
            Caption = 'Alt. Delivery Fri';

            trigger OnValidate()
            begin
                if "Alt. Delivery Fri" then begin
                    "Standard Delivery Fri" := false;
                end;
            end;
        }
        field(10016; "Alt. Delivery Sat"; Boolean)
        {
            Caption = 'Alt. Delivery Sat';

            trigger OnValidate()
            begin
                if "Alt. Delivery Sat" then begin
                    "Standard Delivery Sat" := false;
                end;
            end;
        }
        field(10017; "Alt. Delivery Sun"; Boolean)
        {
            Caption = 'Alt. Delivery Sun';

            trigger OnValidate()
            begin
                if "Alt. Delivery Sun" then begin
                    "Standard Delivery Sun" := false;
                end;
            end;
        }
        field(40000; "Pre-Invoice Order Report ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Pre-Invoice Order Report';
            TableRelation = Object.ID WHERE(Type = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Pre-Invoice Order Report Name");
            end;
        }
        field(40001; "Pre-Invoice Order Report Name"; Text[30])
        {
            CalcFormula = Lookup(Object.Name WHERE(Type = CONST(Report),
                                                    ID = FIELD("Pre-Invoice Order Report ID")));
            Caption = 'Pre-Invoice Order Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40002; "Stales CM Report ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Stales CM Report ID';
            TableRelation = Object.ID WHERE(Type = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Stales CM Report Name");
            end;
        }
        field(40003; "Stales CM Report Name"; Text[30])
        {
            CalcFormula = Lookup(Object.Name WHERE(Type = CONST(Report),
                                                    ID = FIELD("Stales CM Report ID")));
            Caption = 'Stales CM Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40004; "Stales CM Return Reason Code"; Code[10])
        {
            Caption = 'Stales CM Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(40010; "Alternate Order Report ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Alternate Order Report ID';
            TableRelation = Object.ID WHERE(Type = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Alternate Order Report Name");
            end;
        }
        field(40011; "Alternate Order Report Name"; Text[30])
        {
            CalcFormula = Lookup(Object.Name WHERE(Type = CONST(Report),
                                                    ID = FIELD("Alternate Order Report ID")));
            Caption = 'Alternate Order Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40050; "B.Post Del. 0-Qty S. Headers"; Enum BPostSHeader)
        {
            Caption = 'B.Post Del. 0-Qty S. Headers';
        }
        field(40060; "Std. Dlvry. Always Print CM"; Boolean)
        {
        }
        field(23019500; "Activate Cut Off Times"; Boolean)
        {
            Caption = 'Activate Cut Off Times';
            Description = 'JF00178SHR';
        }
        field(23019501; "Cut Off Time Monday"; Time)
        {
            Caption = 'Cut Off Time Monday';
            Description = 'JF00178SHR';
        }
        field(23019502; "Cut Off Time Tuesday"; Time)
        {
            Caption = 'Cut Off Time Tuesday';
            Description = 'JF00178SHR';
        }
        field(23019503; "Cut Off Time Wednesday"; Time)
        {
            Caption = 'Cut Off Time Wednesday';
            Description = 'JF00178SHR';
        }
        field(23019504; "Cut Off Time Thursday"; Time)
        {
            Caption = 'Cut Off Time Thursday';
            Description = 'JF00178SHR';
        }
        field(23019505; "Cut Off Time Friday"; Time)
        {
            Caption = 'Cut Off Time Friday';
            Description = 'JF00178SHR';
        }
        field(23019506; "Cut Off Time Saturday"; Time)
        {
            Caption = 'Cut Off Time Saturday';
            Description = 'JF00178SHR';
        }
        field(23019507; "Cut Off Time Sunday"; Time)
        {
            Caption = 'Cut Off Time Sunday';
            Description = 'JF00178SHR';
        }
        field(23019509; "Qck. Ord. Lead Time Mon (Days)"; Integer)
        {
            Description = 'JF00178SHR';
        }
        field(23019510; "Qck. Ord. Lead Time Tue (Days)"; Integer)
        {
            Description = 'JF00178SHR';
        }
        field(23019511; "Qck. Ord. Lead Time Wed (Days)"; Integer)
        {
            Description = 'JF00178SHR';
        }
        field(23019512; "Qck. Ord. Lead Time Thu (Days)"; Integer)
        {
            Description = 'JF00178SHR';
        }
        field(23019513; "Qck. Ord. Lead Time Fri (Days)"; Integer)
        {
            Description = 'JF00178SHR';
        }
        field(23019514; "Qck. Ord. Lead Time Sat (Days)"; Integer)
        {
            Description = 'JF00178SHR';
        }
        field(23019515; "Qck. Ord. Lead Time Sun (Days)"; Integer)
        {
            Description = 'JF00178SHR';
        }
        field(23019516; "Override Loc. from Route Temp."; Boolean)
        {
            Caption = 'Override Loc. from Route Temp.';
            Description = 'JF00165SHR';
        }
        field(23019517; "Invoice Report ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Invoice Report ID';
            Description = 'JF00165SHR';
            TableRelation = Object.ID WHERE(Type = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Invoice Report Name");
            end;
        }
        field(23019518; "Invoice Report Name"; Text[30])
        {
            CalcFormula = Lookup(Object.Name WHERE(Type = CONST(Report),
                                                    ID = FIELD("Invoice Report ID")));
            Caption = 'Invoice Report Name';
            Description = 'JF00165SHR';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23019519; "Cr. Memo Report ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Cr. Memo Report ID';
            Description = 'JF00165SHR';
            TableRelation = Object.ID WHERE(Type = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Cr. Memo Report Name");
            end;
        }
        field(23019520; "Cr. Memo Report Name"; Text[30])
        {
            CalcFormula = Lookup(Object.Name WHERE(Type = CONST(Report),
                                                    ID = FIELD("Cr. Memo Report ID")));
            Caption = 'Cr. Memo Report Name';
            Description = 'JF00165SHR';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23019521; "Sort Order Lines By"; Enum SortOrderLine)
        {
            Caption = 'Sort Order Lines By';
            Description = 'JF01205SHR';
        }
        field(23019522; "Blocked Items on Activate"; Enum BlockedItemsOnActivate)
        {
            Caption = 'Blocked Items on Activate';
            Description = 'JF4802SHR';
        }
        field(23019528; "RP Reclass Jnl. Posting Date"; Enum ReclassJnlDate)
        {
            Caption = 'Route Pack Reclass Jnl. Posting Date';
            Description = 'JF7555DD';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    [Scope('Internal')]
    procedure GetStandardDeliveryFilter() ptxt: Text[250]
    var
        lblnGotOne: Boolean;
    begin
        if "Standard Delivery Mon" then begin
            lblnGotOne := true;
            ptxt := 'Monday';
        end;
        if "Standard Delivery Tues" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Tuesday';
        end;
        if "Standard Delivery Weds" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Wednesday';
        end;
        if "Standard Delivery Thurs" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Thursday';
        end;
        if "Standard Delivery Fri" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Friday';
        end;
        if "Standard Delivery Sat" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Saturday';
        end;
        if "Standard Delivery Sun" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Sunday';
        end;
    end;

    [Scope('Internal')]
    procedure GetAlternateDeliveryFilter() ptxt: Text[250]
    var
        lblnGotOne: Boolean;
    begin
        if "Alt. Delivery Mon" then begin
            lblnGotOne := true;
            ptxt := 'Monday';
        end;
        if "Alt. Delivery Tues" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Tuesday';
        end;
        if "Alt. Delivery Weds" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Wednesday';
        end;
        if "Alt. Delivery Thurs" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Thursday';
        end;
        if "Alt. Delivery Fri" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Friday';
        end;
        if "Alt. Delivery Sat" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Saturday';
        end;
        if "Alt. Delivery Sun" then begin
            if lblnGotOne then begin
                ptxt := ptxt + '|';
            end;
            lblnGotOne := true;
            ptxt := ptxt + 'Sunday';
        end;
    end;

    [Scope('Internal')]
    procedure IsWeekdayStandardDelivery(lintWeekday: Integer) pbln: Boolean
    begin

        case lintWeekday of
            1:
                exit("Standard Delivery Mon");
            2:
                exit("Standard Delivery Tues");
            3:
                exit("Standard Delivery Weds");
            4:
                exit("Standard Delivery Thurs");
            5:
                exit("Standard Delivery Fri");
            6:
                exit("Standard Delivery Sat");
            7:
                exit("Standard Delivery Sun");
        end;
    end;

    [Scope('Internal')]
    procedure IsWeekdayAltDelivery(lintWeekday: Integer) pbln: Boolean
    begin

        case lintWeekday of
            1:
                exit("Alt. Delivery Mon");
            2:
                exit("Alt. Delivery Tues");
            3:
                exit("Alt. Delivery Weds");
            4:
                exit("Alt. Delivery Thurs");
            5:
                exit("Alt. Delivery Fri");
            6:
                exit("Alt. Delivery Sat");
            7:
                exit("Alt. Delivery Sun");
        end;
    end;
}

