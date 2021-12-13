table 14229410 "Commodity Allocation Line ELA"
{
    // ENRE1.00 2021-09-08 AJ



    // 
    // ENRE1.00
    //   - - new flowfilters:
    //   "Functional Area", "Source Type", "Source No.", "Source Line No."
    //   - modified function CheckOverlap, CheckOverlapRename

    DrillDownPageID = "Commodity Allocations ELA";  //Commodity Allocations
    LookupPageID = "Commodity Allocations ELA";

    fields
    {
        field(1; "Recipient Agency No."; Code[20])
        {
            Caption = 'Recipient Agency No.';
            NotBlank = true;
            TableRelation = "Recipient Agency ELA";
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            NotBlank = true;

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(4; "Commodity No."; Code[20])
        {
            Caption = 'Commodity No.';
            NotBlank = true;
            TableRelation = "Commodity ELA";
        }
        field(10; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            NotBlank = true;

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin

                if Quantity < xRec.Quantity then begin
                    CalcFields("Quantity Used");
                    if (Quantity - "Quantity Used") < 0 then begin
                        Error(Text001);
                    end;
                end;
            end;
        }
        field(12; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DecimalPlaces = 2 : 5;
        }
        field(13; "Quantity Used"; Decimal)
        {
            CalcFormula = Sum("Commodity Ledger ELA".Quantity WHERE("Commodity No." = FIELD("Commodity No."),
                                                                 "Recipient Agency No." = FIELD("Recipient Agency No."),
                                                                 "Vendor No." = FIELD("Vendor No."),
                                                                 "Posting Date" = FIELD(FILTER("Used Date Range")),
                                                                 "Functional Area" = FIELD("Functional Area"),
                                                                 "Source Type" = FIELD("Source Type"),
                                                                 "Source No." = FIELD("Source No."),
                                                                 "Source Line No." = FIELD("Source Line No.")));
            Caption = 'Quantity Used';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Amount (LCY) Used"; Decimal)
        {
            CalcFormula = Sum("Commodity Ledger ELA"."Amount (LCY)" WHERE("Commodity No." = FIELD("Commodity No."),
                                                                       "Recipient Agency No." = FIELD("Recipient Agency No."),
                                                                       "Vendor No." = FIELD("Vendor No."),
                                                                       "Posting Date" = FIELD(FILTER("Used Date Range")),
                                                                       "Functional Area" = FIELD("Functional Area"),
                                                                       "Source Type" = FIELD("Source Type"),
                                                                       "Source No." = FIELD("Source No."),
                                                                       "Source Line No." = FIELD("Source Line No.")));
            Caption = 'Amount (LCY) Used';
            DecimalPlaces = 2 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Used Date Range"; Text[250])
        {
        }
        field(40; "Functional Area"; Option)
        {
            FieldClass = FlowFilter;
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(50; "Source Type"; Option)
        {
            FieldClass = FlowFilter;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(60; "Source No."; Code[20])
        {
            FieldClass = FlowFilter;

            trigger OnValidate()
            var
                lrecSalesHeader: Record "Sales Header";
                lrecPurchHeader: Record "Purchase Header";
            begin
            end;
        }
        field(70; "Source Line No."; Integer)
        {
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Recipient Agency No.", "Vendor No.", "Commodity No.", "Starting Date", "Ending Date")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin

        CheckOverlap;

        "Used Date Range" := Format("Starting Date") + '..' + Format("Ending Date");
    end;

    trigger OnRename()
    begin

        CheckOverlapRename;

        "Used Date Range" := Format("Starting Date") + '..' + Format("Ending Date");
    end;

    var
        Text000: Label '%1 cannot be after %2';
        Text001: Label 'Quantity cannot be less than Quantity Used.';
        Text002: Label 'Overlapping Dates exist. Commodity Allocation Line cannot be entered.';


    procedure CheckOverlap()
    var
        lrecCommAllLine: Record "Commodity Allocation Line ELA";
    begin

        lrecCommAllLine.SetRange("Recipient Agency No.", "Recipient Agency No.");
        lrecCommAllLine.SetRange("Vendor No.", "Vendor No.");
        lrecCommAllLine.SetRange("Commodity No.", "Commodity No.");
        lrecCommAllLine.SetFilter("Starting Date", '%1..%2', "Starting Date", "Ending Date");
        if lrecCommAllLine.FindFirst then begin
            Error(Text002);
        end;

        //<ENRE1.00>
        lrecCommAllLine.SetRange("Starting Date");
        lrecCommAllLine.SetFilter("Ending Date", '%1..%2', "Starting Date", "Ending Date");
        if lrecCommAllLine.FindFirst then begin
            Error(Text002);
        end;

        lrecCommAllLine.SetFilter("Starting Date", '%1|<=%2', "Starting Date", "Ending Date");
        lrecCommAllLine.SetFilter("Ending Date", '%1|>=%2', "Starting Date", "Ending Date");
        if lrecCommAllLine.FindFirst then begin
            Error(Text002);
        end;
        //</ENRE1.00>
    end;


    procedure CheckOverlapRename()
    var
        lrecCommAllLine: Record "Commodity Allocation Line ELA";
        lrecCommAllLineTemp: Record "Commodity Allocation Line ELA" temporary;
    begin
        lrecCommAllLine.SetRange("Recipient Agency No.", "Recipient Agency No.");
        lrecCommAllLine.SetRange("Vendor No.", "Vendor No.");
        lrecCommAllLine.SetRange("Commodity No.", "Commodity No.");
        lrecCommAllLine.SetFilter("Starting Date", '<>%1', "Starting Date");
        lrecCommAllLine.SetFilter("Ending Date", '<>%1', "Ending Date");
        if lrecCommAllLine.FindSet then begin
            repeat
                lrecCommAllLineTemp := lrecCommAllLine;
                lrecCommAllLineTemp.Insert;
            until lrecCommAllLine.Next = 0;
        end;


        lrecCommAllLineTemp.SetRange("Recipient Agency No.", "Recipient Agency No.");
        lrecCommAllLineTemp.SetRange("Vendor No.", "Vendor No.");
        lrecCommAllLineTemp.SetRange("Commodity No.", "Commodity No.");
        lrecCommAllLineTemp.SetFilter("Starting Date", '%1..%2', "Starting Date", "Ending Date");
        if lrecCommAllLineTemp.FindSet then begin
            Error(Text002);
        end;

        //<ENRE1.00>
        lrecCommAllLine.SetRange("Starting Date");
        lrecCommAllLine.SetFilter("Ending Date", '%1..%2', "Starting Date", "Ending Date");
        if lrecCommAllLine.FindFirst then begin
            Error(Text002);
        end;

        lrecCommAllLine.SetFilter("Starting Date", '%1|<=%2', "Starting Date", "Ending Date");
        lrecCommAllLine.SetFilter("Ending Date", '%1|>=%2', "Starting Date", "Ending Date");
        if lrecCommAllLine.FindFirst then begin
            Error(Text002);
        end;
        //</ENRE1.00>
    end;
}

