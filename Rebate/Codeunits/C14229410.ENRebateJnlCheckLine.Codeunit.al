codeunit 14229410 "Rebate Jnl.-Check Line ELA"
{

    // ENRE1.00 2021-09-08 AJ
    //  - modified OnRun to handle Purhcase Rebates

    TableNo = "Rebate Journal Line ELA";

    trigger OnRun()
    var
        lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if EmptyLine then
            exit;

        //<ENRE1.00>
        if "Applies-To Source Type" in ["Applies-To Source Type"::"Posted Sales Invoice",
                                        "Applies-To Source Type"::"Posted Sales Cr. Memo",
                                        "Applies-To Source Type"::Customer] then begin
            //</ENRE1.00>
            TestField("Applies-To Customer No.");
            TestField("Applies-To Source No.");

            if "Applies-To Source Type" <> "Applies-To Source Type"::Customer then
                TestField("Applies-To Source Line No.");

            TestField("Amount (LCY)");
            TestField("Posting Date");

            if "Applies-To Source Type" = "Applies-To Source Type"::Customer then begin
                if "Applies-To Customer No." <> "Applies-To Source No." then
                    Error(gText000, FieldCaption("Applies-To Customer No."), FieldCaption("Applies-To Source No."));
            end;

            //<ENRE1.00>
        end else begin
            TestField("Applies-To Vendor No.");
            TestField("Applies-To Source No.");

            if "Applies-To Source Type" <> "Applies-To Source Type"::Vendor then
                TestField("Applies-To Source Line No.");

            TestField("Amount (LCY)");
            TestField("Posting Date");

            if "Applies-To Source Type" = "Applies-To Source Type"::Vendor then begin
                if "Applies-To Vendor No." <> "Applies-To Source No." then
                    Error(gText000, FieldCaption("Applies-To Vendor No."), FieldCaption("Applies-To Source No."));
            end;

        end;
        //</ENRE1.00>
    end;

    var
        gText000: Label '%1 must be the same as %2';
}

