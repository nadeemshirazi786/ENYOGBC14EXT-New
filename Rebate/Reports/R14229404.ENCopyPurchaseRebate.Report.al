report 14229404 "Copy Purchase Rebate ELA"
{
    // 
    // ENRE1.00 2021-08-26 AJ
    //    - add support to copy Purchase Rebate Customers if "Copy Header" is true


    ProcessingOnly = true;
    ShowPrintStatus = true;
    UseRequestPage = true;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            trigger OnAfterGetRecord()
            begin
                CopyRebate;
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
                    field(goptCopyFrom; goptCopyFrom)
                    {
                        ApplicationArea = All;
                        Caption = 'From Rebate Type';
                    }
                    field(gcodFromRebateCode; gcodFromRebateCode)
                    {
                        ApplicationArea = All;
                        Caption = 'From Rebate Code';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            lrecPurchRebate: Record "Purchase Rebate Header ELA";
                            lrecCancelledRebate: Record "Cancel Purch. Rbt Header ELA";
                        begin
                            case goptCopyFrom of
                                goptCopyFrom::"Active Rebate":
                                    begin
                                        lrecPurchRebate.Reset;

                                        if PAGE.RunModal(0, lrecPurchRebate) = ACTION::LookupOK then
                                            gcodFromRebateCode := lrecPurchRebate.Code;
                                    end;
                                goptCopyFrom::"Cancelled Rebate":
                                    begin
                                        lrecCancelledRebate.Reset;

                                        if PAGE.RunModal(0, lrecCancelledRebate) = ACTION::LookupOK then
                                            gcodFromRebateCode := lrecCancelledRebate.Code;
                                    end;
                            end;
                        end;
                    }
                    field(gcodToRebateCode; gcodToRebateCode)
                    {
                        ApplicationArea = All;
                        Caption = 'To Rebate Code';
                        Editable = false;
                        TableRelation = "Rebate Header ELA";
                    }
                    field(gblnCopyHeader; gblnCopyHeader)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Header';
                    }
                    field(gblnCopyLines; gblnCopyLines)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Lines';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            gblnCopyHeader := true;
            gblnCopyLines := true;
        end;
    }

    labels
    {
    }

    var
        gcodFromRebateCode: Code[20];
        gcodToRebateCode: Code[20];
        gconText001: Label 'From Rebate Code and To Rebate Code must be different.';
        gconText002: Label 'From Rebate Code cannot be blank';
        gblnCopyHeader: Boolean;
        grecToRebate: Record "Purchase Rebate Header ELA";
        gblnCopyLines: Boolean;
        goptCopyFrom: Option "Active Rebate","Cancelled Rebate";
        gconText003: Label 'To Rebate Code cannot be blank.';


    procedure CopyRebate()
    var
        lrecFromRebate: Record "Purchase Rebate Header ELA";
        lrecFromDetail: Record "Purchase Rebate Line ELA";
        lrecFromComm: Record "Purchase Rbt Comment Line ELA";
        lrecFromCancelledRebate: Record "Cancel Purch. Rbt Header ELA";
        lrecFromCancelledDetail: Record "Cancel Purch. Rbt Line ELA";
        lrecFromCancelledComm: Record "Cancel Purch Rbt Comm Line ELA";
        lrecToDetail: Record "Purchase Rebate Line ELA";
        lrecToComm: Record "Purchase Rbt Comment Line ELA";
        lintLineNo: Integer;
        lrecFromPurchRebateCust: Record "Purchase Rebate Customer ELA";
        lrecCancelledPurchRebateCust: Record "Cancelled Purch. Rbt Cust. ELA";
        lrecToPurchRebateCust: Record "Purchase Rebate Customer ELA";
    begin
        if gcodFromRebateCode = '' then
            Error(gconText002);

        if gcodToRebateCode = '' then
            Error(gconText003);

        if gcodFromRebateCode = gcodToRebateCode then
            Error(gconText001);

        case goptCopyFrom of
            goptCopyFrom::"Active Rebate":
                begin
                    lrecFromRebate.Get(gcodFromRebateCode);

                    if gblnCopyHeader then begin
                        grecToRebate.TransferFields(lrecFromRebate, false);
                        grecToRebate.Blocked := false;
                        grecToRebate.Modify;

                        //<ENRE1.00>
                        if (
                          (lrecFromRebate."Rebate Type" = lrecFromRebate."Rebate Type"::"Sales-Based")
                        ) then begin
                            lrecFromPurchRebateCust.Reset;
                            lrecFromPurchRebateCust.SetRange("Purchase Rebate Code", lrecFromRebate.Code);
                            if (
                              (not lrecFromPurchRebateCust.IsEmpty)
                            ) then begin
                                lrecFromPurchRebateCust.FindSet(false);
                                repeat

                                    lrecToPurchRebateCust.Init;
                                    lrecToPurchRebateCust := lrecFromPurchRebateCust;
                                    lrecToPurchRebateCust."Purchase Rebate Code" := grecToRebate.Code;
                                    lrecToPurchRebateCust.Insert(true);

                                until lrecFromPurchRebateCust.Next = 0;
                            end;
                        end;
                        //</ENRE1.00>

                    end;

                    lrecFromComm.Reset;
                    lrecFromComm.SetRange("Purchase Rebate Code", lrecFromRebate.Code);
                    lrecFromComm.SetRange("Line No.");
                    if lrecFromComm.FindSet then begin
                        lrecToComm.Reset;

                        lrecToComm.SetRange("Purchase Rebate Code", grecToRebate.Code);
                        lrecToComm.SetRange("Line No.");

                        if lrecToComm.FindLast then
                            lintLineNo := lrecToComm."Line No." + 10000
                        else
                            lintLineNo := 0;

                        repeat
                            lintLineNo += 10000;

                            lrecToComm.Init;

                            lrecToComm."Purchase Rebate Code" := grecToRebate.Code;
                            lrecToComm."Line No." := lintLineNo;

                            lrecToComm.TransferFields(lrecFromComm, false);

                            lrecToComm.Insert;
                        until lrecFromComm.Next = 0;
                    end;

                    if gblnCopyLines then begin
                        lrecFromDetail.Reset;

                        lrecFromDetail.SetRange("Purchase Rebate Code", lrecFromRebate.Code);
                        lrecFromDetail.SetRange("Line No.");


                        if lrecFromDetail.FindSet then begin
                            lrecToDetail.Reset;

                            lrecToDetail.SetRange("Purchase Rebate Code", grecToRebate.Code);
                            lrecToDetail.SetRange("Line No.");

                            if lrecToDetail.FindLast then
                                lintLineNo := lrecToDetail."Line No." + 10000
                            else
                                lintLineNo := 0;

                            repeat
                                lintLineNo += 10000;

                                lrecToDetail.Init;

                                lrecToDetail."Purchase Rebate Code" := grecToRebate.Code;
                                lrecToDetail."Line No." := lintLineNo;

                                lrecToDetail.Insert(true);

                                lrecToDetail.TransferFields(lrecFromDetail, false);

                                lrecToDetail.Modify;
                            until lrecFromDetail.Next = 0;
                        end;
                    end;
                end;
            goptCopyFrom::"Cancelled Rebate":
                begin
                    lrecFromCancelledRebate.Get(gcodFromRebateCode);
                    if gblnCopyHeader then begin
                        grecToRebate.TransferFields(lrecFromCancelledRebate, false);

                        grecToRebate.Modify;

                        //<ENRE1.00>
                        if (
                          (lrecFromCancelledRebate."Rebate Type" = lrecFromCancelledRebate."Rebate Type"::"Sales-Based")
                        ) then begin
                            lrecCancelledPurchRebateCust.Reset;
                            lrecCancelledPurchRebateCust.SetRange("Cancelled Purch. Rebate Code", lrecFromCancelledRebate.Code);
                            if (
                              (not lrecCancelledPurchRebateCust.IsEmpty)
                            ) then begin
                                lrecCancelledPurchRebateCust.FindSet(false);
                                repeat

                                    lrecToPurchRebateCust.Init;
                                    lrecToPurchRebateCust.TransferFields(lrecCancelledPurchRebateCust, false);
                                    lrecToPurchRebateCust.Validate("Purchase Rebate Code", grecToRebate.Code);
                                    lrecToPurchRebateCust.Validate("Customer No.", lrecCancelledPurchRebateCust."Customer No.");
                                    lrecToPurchRebateCust.Insert(true);

                                until lrecCancelledPurchRebateCust.Next = 0;
                            end;
                        end;
                        //</ENRE1.00>

                    end;

                    lrecFromCancelledComm.Reset;
                    lrecFromCancelledComm.SetRange("Purchase Rebate Code", lrecFromCancelledRebate.Code);
                    lrecFromCancelledComm.SetRange("Line No.");
                    if lrecFromCancelledComm.FindSet then begin
                        lrecToComm.Reset;
                        lrecToComm.SetRange("Purchase Rebate Code", grecToRebate.Code);
                        lrecToComm.SetRange("Line No.");
                        if lrecToComm.FindLast then
                            lintLineNo := lrecToComm."Line No." + 10000
                        else
                            lintLineNo := 0;
                        repeat
                            lintLineNo += 10000;
                            lrecToComm.Init;
                            lrecToComm."Purchase Rebate Code" := grecToRebate.Code;
                            lrecToComm."Line No." := lintLineNo;
                            lrecToComm.TransferFields(lrecFromCancelledComm, false);
                            lrecToComm.Insert;
                        until lrecFromCancelledComm.Next = 0;
                    end;

                    if gblnCopyLines then begin
                        lrecFromCancelledDetail.Reset;
                        lrecFromCancelledDetail.SetRange("Purchase Rebate Code", lrecFromCancelledRebate.Code);
                        lrecFromCancelledDetail.SetRange("Line No.");
                        if lrecFromCancelledDetail.FindSet then begin
                            lrecToDetail.Reset;
                            lrecToDetail.SetRange("Purchase Rebate Code", grecToRebate.Code);
                            lrecToDetail.SetRange("Line No.");
                            if lrecToDetail.FindLast then
                                lintLineNo := lrecToDetail."Line No." + 10000
                            else
                                lintLineNo := 0;
                            repeat
                                lintLineNo += 10000;
                                lrecToDetail.Init;
                                lrecToDetail."Purchase Rebate Code" := grecToRebate.Code;
                                lrecToDetail."Line No." := lintLineNo;
                                lrecToDetail.Insert(true);
                                lrecToDetail.TransferFields(lrecFromCancelledDetail, false);
                                lrecToDetail.Modify;
                            until lrecFromCancelledDetail.Next = 0;
                        end;
                    end;
                end;
        end;
    end;


    procedure SetCurrentRebate(var precToRebate: Record "Purchase Rebate Header ELA")
    begin
        grecToRebate := precToRebate;
        gcodToRebateCode := precToRebate.Code;
    end;
}

