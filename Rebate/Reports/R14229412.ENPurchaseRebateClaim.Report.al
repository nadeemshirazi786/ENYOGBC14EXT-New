report 14229412 "Purchase Rebate Claim ELA"
{
    //ENRE1.00 2021-09-08 AJ
    // 
    // ENRE1.00
    //    - new report
    // 
    // ENRE1.00
    //    - added rdlc, modified how compnay info populated
    // 
    // ENRE1.00
    //   20130820 - Modified RDLC Layout.
    // ENRE1.00  - Increase Address variables from 50 to 90
    // ENRE1.00  - Fix issue with rebate claim not printing
    DefaultLayout = RDLC;
    RDLCLayout = './PurchaseRebateClaim.rdlc';
    Caption = 'Purchase Rebate Claim';
    ApplicationArea = All;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Rebate Group Code ELA";
            column(FORMAT_TODAY_0_4_; Today)
            {
            }
            column(CompanyAddr_1_; gtxtCompanyAddr[1])
            {
            }
            column(CompanyAddr_2_; gtxtCompanyAddr[2])
            {
            }
            column(CompanyAddr_3_; gtxtCompanyAddr[3])
            {
            }
            column(Vendor_______No__; "No.")
            {
            }
            column(CompanyInfo_Picture; grecCompanyInfo.Picture)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(CompanyAddr_4_; gtxtCompanyAddr[4])
            {
            }
            column(CompanyAddr_5_; gtxtCompanyAddr[5])
            {
            }
            column(CompanyAddr_6_; gtxtCompanyAddr[6])
            {
            }
            column(CompanyAddr_7_; gtxtCompanyAddr[7])
            {
            }
            column(CompanyAddr_8_; gtxtCompanyAddr[8])
            {
            }
            column(CompanyAddr_9_; gtxtCompanyAddr[9])
            {
            }
            column(CompanyAddr_10_; gtxtCompanyAddr[10])
            {
            }
            column(Rebate_ClaimsCaption; Rebate_ClaimsCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Created_at_Caption; Created_at_CaptionLbl)
            {
            }
            column(Vendor_Caption; Vendor_CaptionLbl)
            {
            }
            column(Rebate_Ledger_Entry__Item_No__Caption; "Rebate Ledger Entry".FieldCaption("Item No."))
            {
            }
            column(QuantityCaption; QuantityCaptionLbl)
            {
            }
            column(Item_DescriptionCaption; Item_DescriptionCaptionLbl)
            {
            }
            column(UOMCaption; UOMCaptionLbl)
            {
            }
            column(COSTCaption; COSTCaptionLbl)
            {
            }
            column(Ext_Caption; Ext_CaptionLbl)
            {
            }
            column(Rebate_Unit_RateCaption; Rebate_Unit_RateCaptionLbl)
            {
            }
            column(Extended_RebateCaption; Extended_RebateCaptionLbl)
            {
            }
            column(Total_Caption; Total_CaptionLbl)
            {
            }
            dataitem("Rebate Ledger Entry"; "Rebate Ledger Entry ELA")
            {
                DataItemLink = "Pay-to Vendor No." = FIELD("No.");
                DataItemTableView = SORTING("Pay-to Vendor No.", "Functional Area", "Source Type", "Source No.", "Source Line No.", "Item No.", "Rebate Code") WHERE("Functional Area" = CONST(Purchase), "Source Type" = CONST("Posted Invoice"), Claimed = CONST(false));
                RequestFilterFields = "Posting Date", "Rebate Type";
                column(Order______Source_No__; 'Order:' + "Source No.")
                {
                }
                column(gdatPostingDate; gdatPostingDate)
                {
                }
                column(gtxtCustVendName; gtxtCustVendName)
                {
                }
                column(Phone_____gtxtCustVendPhone; 'Phone:' + gtxtCustVendPhone)
                {
                }
                column(Fax_____gtxtCustVendFax; 'Fax:' + gtxtCustVendFax)
                {
                }
                column(gdecRate; gdecRate)
                {
                }
                column(gdecQty; gdecQty)
                {
                }
                column(Rebate_Ledger_Entry__Item_No__; "Item No.")
                {
                }
                column(gcodUOM; gcodUOM)
                {
                }
                column(gdecUnitPriceCost; gdecUnitPriceCost)
                {
                }
                column(gtxtItemDescp; gtxtItemDescp)
                {
                }
                column(gdecQty___gdecUnitPriceCost; gdecQty * gdecUnitPriceCost)
                {
                }
                column(gdecQty_gdecRate; gdecQty * gdecRate)
                {
                }
                column(Rebate_Ledger_Entry_Entry_No_; "Entry No.")
                {
                }
                column(Rebate_Ledger_Entry_Source_No_; "Source No.")
                {
                }
                column(Rebate_Ledger_Entry_Source_Line_No_; "Source Line No.")
                {
                }
                column(Rebate_Ledger_Entry_Pay_to_Vendor_No_; "Pay-to Vendor No.")
                {
                }
                column(gdecTotalExt; gdecTotalExt)
                {
                }
                column(gdecTotalExtRebate; gdecTotalExtRebate)
                {
                }
                column(PrintFooter; PrintFooter)
                {
                }

                trigger OnAfterGetRecord()
                var
                    lrecRLE: Record "Rebate Ledger Entry ELA";
                    lrecVLE: Record "Vendor Ledger Entry";
                    lcduPurchRebateMgmt: Codeunit "Purchase Rebate Management ELA";
                begin
                    OnLineNumber := OnLineNumber + 1;   //<ENRE1.00/>

                    //group by line no, rebate no

                    //modify rebate le with claim no.
                    //modify all adjustments with claim no.
                    //add all adjustment amounts and current rebate Amount  = MCB
                    //MCB/Qty from LIne = MCB ($/Unit)

                    //If option checked  "Accrue Rebates to Vendor"
                    //post each rebate ledger entry that is processed to the vendor
                    //end else
                    //Check if accrued, if so modify the VLE Ext Doc No with Claim No.

                    if gcodClaimRefNo = '' then begin
                        gcodClaimRefNo := gcduNoSeriesMgt.GetNextNo(grecPurchSetup."Rbt Claim Reference Nos. ELA", WorkDate, true);
                    end;

                    if (gcodLastDocNo <> "Rebate Ledger Entry"."Source No.") or
                       (gcodLastRebate <> "Rebate Ledger Entry"."Rebate Code") or
                       (gintLastLineNo <> "Rebate Ledger Entry"."Source Line No.") then begin
                        gdecQty := 0;
                        gdecRate := 0;
                    end;

                    lrecRLE.Get("Rebate Ledger Entry"."Entry No.");
                    lrecRLE.Claimed := true;
                    lrecRLE."Claimed Datetime" := CreateDateTime(Today, Time);
                    lrecRLE."Claim Reference No." := gcodClaimRefNo;
                    lrecRLE.Modify;

                    if "Rebate Ledger Entry"."Posted To Vendor" then begin
                        lrecVLE.SetRange("Posted Rebate Entry No. ELA", "Rebate Ledger Entry"."Entry No.");
                        if lrecVLE.FindSet(true) then begin
                            repeat
                                lrecVLE."External Document No." := gcodClaimRefNo;
                                lrecVLE.Modify;
                            until lrecVLE.Next = 0;
                        end;
                    end else begin
                        if gblnAccrueRebatesToVendor then begin
                            lcduPurchRebateMgmt.SkipDialogMode(true);
                            lrecRLE.SetRange("Entry No.", "Rebate Ledger Entry"."Entry No.");
                            lcduPurchRebateMgmt.AccrueRebateFromVendor(lrecRLE, lrecRLE."Post-to Vendor No.");
                        end;
                    end;


                    //if already found line dont need to repeat

                    if (gcodLastDocNo <> "Rebate Ledger Entry"."Source No.") or
                       (gintLastLineNo <> "Rebate Ledger Entry"."Source Line No.") then begin

                        case "Rebate Ledger Entry"."Source Type" of
                            "Rebate Ledger Entry"."Source Type"::"Posted Invoice":
                                begin
                                    if "Rebate Ledger Entry"."Rebate Type" = "Rebate Ledger Entry"."Rebate Type"::"Sales-Based" then begin
                                        grecSIH.Get("Rebate Ledger Entry"."Source No.");
                                        gdatPostingDate := grecSIH."Posting Date";
                                        gtxtCustVendName := grecSIH."Sell-to Customer Name";

                                        grecCustomer.Get(grecSIH."Sell-to Customer No.");
                                        gtxtCustVendPhone := grecCustomer."Phone No.";
                                        gtxtCustVendFax := grecCustomer."Fax No.";

                                        grecSIL.Get("Rebate Ledger Entry"."Source No.", "Rebate Ledger Entry"."Source Line No.");
                                        gtxtItemDescp := grecSIL.Description;
                                        gdecQty := grecSIL.Quantity;
                                        gcodUOM := grecSIL."Unit of Measure Code";
                                        gdecUnitPriceCost := grecSIL."Unit Price";

                                    end else begin
                                        grecPIH.Get("Rebate Ledger Entry"."Source No.");
                                        gdatPostingDate := grecPIH."Posting Date";
                                        gtxtCustVendName := grecPIH."Buy-from Vendor Name";

                                        grecVendor.Get(grecPIH."Buy-from Vendor No.");
                                        gtxtCustVendPhone := grecVendor."Phone No.";
                                        gtxtCustVendFax := grecVendor."Fax No.";

                                        grecPIL.Get("Rebate Ledger Entry"."Source No.", "Rebate Ledger Entry"."Source Line No.");
                                        gtxtItemDescp := grecPIL.Description;
                                        gdecQty := grecPIL.Quantity;
                                        gcodUOM := grecPIL."Unit of Measure Code";
                                        gdecUnitPriceCost := grecPIL."Unit Cost (LCY)";

                                    end;
                                end;
                        end;
                    end;

                    if gdecQty <> 0 then begin
                        gdecRate := gdecRate + ("Rebate Ledger Entry"."Amount (LCY)" / gdecQty);
                    end;

                    gcodLastDocNo := "Rebate Ledger Entry"."Source No.";
                    gintLastLineNo := "Rebate Ledger Entry"."Source Line No.";
                    gcodLastRebate := "Rebate Ledger Entry"."Rebate Code";

                    //<ENRE1.00>
                    gdecTotalExt := gdecQty * gdecUnitPriceCost;
                    gdecTotalExtRebate := gdecQty * gdecRate;
                    if OnLineNumber = NumberOfLines then
                        PrintFooter := true;
                    //</ENRE1.00>
                end;

                trigger OnPreDataItem()
                begin
                    //<ENRE1.00>
                    NumberOfLines := "Rebate Ledger Entry".Count;
                    OnLineNumber := 0;
                    PrintFooter := false;
                    //</ENRE1.00>
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(gcodClaimRefNo);
                Clear(gdecTotalExt);
                Clear(gdecTotalExtRebate);
            end;

            trigger OnPreDataItem()
            begin
                grecPurchSetup.Get;
                grecPurchSetup.TestField("Rbt Claim Reference Nos. ELA");

                CurrReport.CreateTotals(gdecTotalExt, gdecTotalExtRebate);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(gblnAccrueRebatesToVendor; gblnAccrueRebatesToVendor)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Rebates to Vendor';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        lintCount: Integer;
        lblnNotEmpty: Boolean;
    begin
        grecCompanyInfo.Get;
        grecCompanyInfo.CalcFields(Picture);

        gcduFormatAddr.Company(gtxtCompanyAddrInitial, grecCompanyInfo);


        //<ENRE1.00>
        repeat
            lintCount += 1;
            gtxtCompanyAddr[lintCount] := gtxtCompanyAddrInitial[lintCount];
        until lintCount = 8;

        lintCount := 9;
        repeat
            lintCount -= 1;
            if gtxtCompanyAddr[lintCount] <> '' then begin
                lblnNotEmpty := true;
            end;

        until lblnNotEmpty;
        lintCount += 1;
        gtxtCompanyAddr[lintCount] := 'Phone No.: ' + grecCompanyInfo."Phone No.";
        lintCount += 1;
        gtxtCompanyAddr[lintCount] := 'Fax No.: ' + grecCompanyInfo."Fax No.";
        //</ENRE1.00>
    end;

    var
        grecCompanyInfo: Record "Company Information";
        grecPurchSetup: Record "Purchases & Payables Setup";
        grecPIH: Record "Purch. Inv. Header";
        grecPIL: Record "Purch. Inv. Line";
        grecSIH: Record "Sales Invoice Header";
        grecSIL: Record "Sales Invoice Line";
        grecVendor: Record Vendor;
        grecCustomer: Record Customer;
        gcduNoSeriesMgt: Codeunit NoSeriesManagement;
        gcduFormatAddr: Codeunit "Format Address";
        gblnAccrueRebatesToVendor: Boolean;
        gcodClaimRefNo: Code[20];
        gcodUOM: Code[10];
        gcodLastDocNo: Code[20];
        gcodLastRebate: Code[20];
        gdecQty: Decimal;
        gdecUnitPriceCost: Decimal;
        gdecRate: Decimal;
        gdecTotalExt: Decimal;
        gdecTotalExtRebate: Decimal;
        gdatPostingDate: Date;
        gtxtCompanyAddr: array[10] of Text[90];
        gtxtCompanyAddrInitial: array[8] of Text[90];
        gtxtCustVendName: Text[50];
        gtxtCustVendPhone: Text[30];
        gtxtCustVendFax: Text[30];
        gtxtItemDescp: Text[50];
        gintLastLineNo: Integer;
        Rebate_ClaimsCaptionLbl: Label 'Rebate Claims';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Created_at_CaptionLbl: Label 'Created at:';
        Vendor_CaptionLbl: Label 'Vendor:';
        QuantityCaptionLbl: Label 'Quantity';
        Item_DescriptionCaptionLbl: Label 'Item Description';
        UOMCaptionLbl: Label 'UOM';
        COSTCaptionLbl: Label 'COST';
        Ext_CaptionLbl: Label 'Ext.';
        Rebate_Unit_RateCaptionLbl: Label 'Rebate Unit Rate';
        Extended_RebateCaptionLbl: Label 'Extended Rebate';
        Total_CaptionLbl: Label 'Total:';
        PrintFooter: Boolean;
        NumberOfLines: Integer;
        OnLineNumber: Integer;
}

