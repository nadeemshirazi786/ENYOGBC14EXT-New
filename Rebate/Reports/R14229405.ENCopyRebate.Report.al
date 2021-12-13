report 14229405 "Copy Rebate ELA"
{
    //ENRE1.00 2021-09-08 AJ
    // 
    // ENRE1.00 - Copy Rebate Function
    //    - new processing only report
    //              * will copy Rebate Header/Detail information from one rebate to another
    //              * existing records for the destination rebate will not be overwritten
    //              * option for user to copy rebate header information
    // 
    // ENRE1.00
    //    - handle blocked rebates


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
                            lrecRebate: Record "Rebate Header ELA";
                            lrecCancelledRebate: Record "Cancelled Rebate Header ELA";
                        begin
                            //<ENRE1.00>
                            case goptCopyFrom of
                                goptCopyFrom::"Active Rebate":
                                    begin
                                        lrecRebate.Reset;

                                        if PAGE.RunModal(0, lrecRebate) = ACTION::LookupOK then
                                            gcodFromRebateCode := lrecRebate.Code;
                                    end;
                                goptCopyFrom::"Cancelled Rebate":
                                    begin
                                        lrecCancelledRebate.Reset;

                                        if PAGE.RunModal(0, lrecCancelledRebate) = ACTION::LookupOK then
                                            gcodFromRebateCode := lrecCancelledRebate.Code;
                                    end;
                            end;
                            //</ENRE1.00>
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
        grecToRebate: Record "Rebate Header ELA";
        gblnCopyLines: Boolean;
        goptCopyFrom: Option "Active Rebate","Cancelled Rebate";
        gconText003: Label 'To Rebate Code cannot be blank.';


    procedure CopyRebate()
    var
        lrecFromRebate: Record "Rebate Header ELA";
        lrecFromDetail: Record "Rebate Line ELA";
        lrecFromComm: Record "Rebate Comment Line ELA";
        lrecFromCancelledRebate: Record "Cancelled Rebate Header ELA";
        lrecFromCancelledDetail: Record "Cancelled Rebate Line ELA";
        lrecFromCancelledComm: Record "Cancel Rbt Comment Line ELA";
        lrecToDetail: Record "Rebate Line ELA";
        lrecToComm: Record "Rebate Comment Line ELA";
        lintLineNo: Integer;
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

                    //-- ******************************************
                    //-- Copy Rebate Header information if selected
                    //-- ******************************************
                    if gblnCopyHeader then begin
                        grecToRebate.TransferFields(lrecFromRebate, false);

                        //<ENRE1.00>
                        grecToRebate.Blocked := false;
                        //</ENRE1.00>

                        grecToRebate.Modify;
                    end;

                    //-- **************************
                    //-- Copy Rebate Comment records
                    //-- **************************
                    lrecFromComm.Reset;

                    lrecFromComm.SetRange("Rebate Code", lrecFromRebate.Code);
                    lrecFromComm.SetRange("Line No.");


                    if lrecFromComm.FindSet then begin
                        lrecToComm.Reset;

                        lrecToComm.SetRange("Rebate Code", grecToRebate.Code);
                        lrecToComm.SetRange("Line No.");

                        if lrecToComm.FindLast then
                            lintLineNo := lrecToComm."Line No." + 10000
                        else
                            lintLineNo := 0;

                        repeat
                            lintLineNo += 10000;

                            lrecToComm.Init;

                            lrecToComm."Rebate Code" := grecToRebate.Code;
                            lrecToComm."Line No." := lintLineNo;

                            lrecToComm.TransferFields(lrecFromComm, false);

                            lrecToComm.Insert;
                        until lrecFromComm.Next = 0;
                    end;

                    //-- **************************
                    //-- Copy Rebate Detail records
                    //-- **************************
                    if gblnCopyLines then begin
                        lrecFromDetail.Reset;

                        lrecFromDetail.SetRange("Rebate Code", lrecFromRebate.Code);
                        lrecFromDetail.SetRange("Line No.");


                        if lrecFromDetail.FindSet then begin
                            lrecToDetail.Reset;

                            lrecToDetail.SetRange("Rebate Code", grecToRebate.Code);
                            lrecToDetail.SetRange("Line No.");

                            if lrecToDetail.FindLast then
                                lintLineNo := lrecToDetail."Line No." + 10000
                            else
                                lintLineNo := 0;

                            repeat
                                lintLineNo += 10000;

                                lrecToDetail.Init;

                                lrecToDetail."Rebate Code" := grecToRebate.Code;
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

                    //-- ******************************************
                    //-- Copy Rebate Header information if selected
                    //-- ******************************************
                    if gblnCopyHeader then begin
                        grecToRebate.TransferFields(lrecFromCancelledRebate, false);

                        grecToRebate.Modify;
                    end;

                    //-- **************************
                    //-- Copy Rebate Comment records
                    //-- **************************
                    lrecFromCancelledComm.Reset;

                    lrecFromCancelledComm.SetRange("Rebate Code", lrecFromCancelledRebate.Code);
                    lrecFromCancelledComm.SetRange("Line No.");


                    if lrecFromCancelledComm.FindSet then begin
                        lrecToComm.Reset;

                        lrecToComm.SetRange("Rebate Code", grecToRebate.Code);
                        lrecToComm.SetRange("Line No.");

                        if lrecToComm.FindLast then
                            lintLineNo := lrecToComm."Line No." + 10000
                        else
                            lintLineNo := 0;

                        repeat
                            lintLineNo += 10000;

                            lrecToComm.Init;

                            lrecToComm."Rebate Code" := grecToRebate.Code;
                            lrecToComm."Line No." := lintLineNo;

                            lrecToComm.TransferFields(lrecFromCancelledComm, false);

                            lrecToComm.Insert;
                        until lrecFromCancelledComm.Next = 0;
                    end;

                    //-- **************************
                    //-- Copy Rebate Detail records
                    //-- **************************
                    if gblnCopyLines then begin
                        lrecFromCancelledDetail.Reset;

                        lrecFromCancelledDetail.SetRange("Rebate Code", lrecFromCancelledRebate.Code);
                        lrecFromCancelledDetail.SetRange("Line No.");

                        if lrecFromCancelledDetail.FindSet then begin
                            lrecToDetail.Reset;

                            lrecToDetail.SetRange("Rebate Code", grecToRebate.Code);
                            lrecToDetail.SetRange("Line No.");

                            if lrecToDetail.FindLast then
                                lintLineNo := lrecToDetail."Line No." + 10000
                            else
                                lintLineNo := 0;

                            repeat
                                lintLineNo += 10000;

                                lrecToDetail.Init;

                                lrecToDetail."Rebate Code" := grecToRebate.Code;
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


    procedure SetCurrentRebate(var precToRebate: Record "Rebate Header ELA")
    begin
        grecToRebate := precToRebate;
        gcodToRebateCode := precToRebate.Code;
    end;
}

