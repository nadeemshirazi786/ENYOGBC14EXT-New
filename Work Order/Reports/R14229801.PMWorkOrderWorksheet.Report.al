report 14229801 "PM Work Order Worksheet ELA"
{
    DefaultLayout = RDLC;
    RDLCLayout = './PMWorkOrderWorksheet.rdlc';


    dataset
    {
        dataitem(Table23019260; Table23019260)
        {
            RequestFilterFields = Field1, Field3, Field2, Field11, Field20, Field101, Field100;
            column(Work_Order_Header_PM_Work_Order_No; "PM Work Order No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(CopyTxt; CopyTxt)
                    {
                    }
                    column(USERID; UserId)
                    {
                    }
                    column(CurrReport_PAGENO; CurrReport.PageNo)
                    {
                    }
                    column(COMPANYNAME; CompanyName)
                    {
                    }
                    column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
                    {
                    }
                    column(WOH_Description; Table23019260.Description)
                    {
                    }
                    column(WOH_PM_Proc_VersionActiveVersion; Table23019260."PM Proc. Version No." + '/' + gcodActiveVersion)
                    {
                    }
                    column(WOH_PM_Work_Order_No; Table23019260."PM Work Order No.")
                    {
                    }
                    column(WOH_Work_Order_Freq; Table23019260."Work Order Freq.")
                    {
                    }
                    column(WOH_Last_Work_Order_Date; Table23019260."Last Work Order Date")
                    {
                    }
                    column(WOH_Person_Responsible; Table23019260."Person Responsible")
                    {
                    }
                    column(WOH_Maintenance_Time_WOH_UOM; Format(Table23019260."Maintenance Time") + ' ' + Table23019260."Maintenance UOM")
                    {
                    }
                    column(WOH_PM_Group_Code; Table23019260."PM Group Code")
                    {
                    }
                    column(WOH_Name; Table23019260.Name)
                    {
                    }
                    column(WOH_Serial_No; Table23019260."Serial No.")
                    {
                    }
                    column(WOH_WorkOrder_Date; Table23019260."Work Order Date")
                    {
                    }
                    column(WOH_No; Table23019260."No.")
                    {
                    }
                    column(WOH_Evaluated_At_Qty; Table23019260."Evaluated At Qty.")
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }
                    column(Copy_No; CopyNo)
                    {
                    }
                    dataitem(PMWOCommentsGeneral; "WO Comment")
                    {
                        DataItemTableView = SORTING("PM Work Order No.", "PM WO Line No.", "Line No.") WHERE("PM WO Line No." = CONST(0));
                        column(PMWOCommentsGeneral_Comments; Comments)
                        {
                        }
                        column(PMWOCommentsGeneral_PM_Work_Order_No; "PM Work Order No.")
                        {
                        }
                        column(PMWOCommentsGeneral_PM_WO_Line_No; "PM WO Line No.")
                        {
                        }
                        column(PMWOCommentsGeneral_Line_No; "Line No.")
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            SetRange("PM Work Order No.", Table23019260."PM Work Order No.");
                        end;
                    }
                    dataitem("Work Order Line"; "Work Order Line")
                    {
                        DataItemTableView = SORTING("PM Work Order No.", "Line No.");
                        column(WOL_PM_Measure_Code; "PM Measure Code")
                        {
                        }
                        column(WOL_PM_Unit_of_Measure; "PM Unit of Measure")
                        {
                        }
                        column(WOL_Value_Type; "Value Type")
                        {
                        }
                        column(gvarDesiredValue; gvarDesiredValue)
                        {
                        }
                        column(WOL_Description; Description)
                        {
                        }
                        column(WOL_Decimal_Min; "Decimal Min")
                        {
                        }
                        column(WOL_Decimal_Max; "Decimal Max")
                        {
                        }
                        column(WOL_PM_Work_Order_No; "PM Work Order No.")
                        {
                        }
                        column(WOL__Line_No; "Line No.")
                        {
                        }
                        dataitem("WO Line Result"; "WO Line Result")
                        {
                            DataItemLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM WO Line No." = FIELD("Line No.");
                            DataItemTableView = SORTING("PM Work Order No.", "PM WO Line No.", "Result No.");
                            column(WO_Line_Result_Result_No; "Result No.")
                            {
                            }
                            column(WO_Line_Result_Result_Value; "Result Value")
                            {
                            }
                            column(WO_Line_Result_Calc_Type; "Work Order Line"."Result Calc. Type")
                            {
                            }
                            column(WO_Line_Decimal_Value; "Work Order Line"."Decimal Value")
                            {
                            }
                            column(WO_Line_Result_PM_Work_Order_No; "PM Work Order No.")
                            {
                            }
                            column(WO_Line_Result_PM_WO_Line_No; "PM WO Line No.")
                            {
                            }
                        }
                        dataitem(LineHeader; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                            column(LineHeader_Number; Number)
                            {
                            }

                            trigger OnPreDataItem()
                            begin
                                if not (
                                  "Work Order Line"."PMWO Item Consumption" or
                                  "Work Order Line"."PMWO Resources" or
                                  "Work Order Line"."PMWO Comments")
                                then
                                    CurrReport.Break;
                            end;
                        }
                        dataitem("WO Item Consumption"; "WO Item Consumption")
                        {
                            DataItemLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM WO Line No." = FIELD("Line No.");
                            DataItemTableView = SORTING("PM Work Order No.", "PM WO Line No.", "Line No.");
                            column(WO_Item_Consumption__Item_No__; "Item No.")
                            {
                            }
                            column(WO_Item_Consumption__Unit_of_Measure_; "Unit of Measure")
                            {
                            }
                            column(WO_Item_Consumption__Quantity_Installed_; "Quantity Installed")
                            {
                            }
                            column(WO_Item_Consumption_Description; Description)
                            {
                            }
                            column(WO_Item_Consumption_PM_Work_Order_No_; "PM Work Order No.")
                            {
                            }
                            column(WO_Item_Consumption_PM_WO_Line_No_; "PM WO Line No.")
                            {
                            }
                            column(WO_Item_Consumption_Line_No_; "Line No.")
                            {
                            }

                            trigger OnPreDataItem()
                            begin
                                if not "Work Order Line"."PMWO Item Consumption" then
                                    CurrReport.Break;
                            end;
                        }
                        dataitem("WO Resource"; "WO Resource")
                        {
                            DataItemLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM WO Line No." = FIELD("Line No.");
                            DataItemTableView = SORTING("PM Work Order No.", "PM WO Line No.", "Line No.");
                            column(WO_Resource_Description; Description)
                            {
                            }
                            column(WO_Resource__No__; "No.")
                            {
                            }
                            column(WO_Resource_Type; Type)
                            {
                            }
                            column(WO_Resource_PM_Work_Order_No_; "PM Work Order No.")
                            {
                            }
                            column(WO_Resource_PM_WO_Line_No_; "PM WO Line No.")
                            {
                            }
                            column(WO_Resource_Line_No_; "Line No.")
                            {
                            }

                            trigger OnPreDataItem()
                            begin
                                if not "Work Order Line"."PMWO Resources" then
                                    CurrReport.Break;
                            end;
                        }
                        dataitem("WO Comment"; "WO Comment")
                        {
                            DataItemLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM WO Line No." = FIELD("Line No.");
                            DataItemTableView = SORTING("PM Work Order No.", "PM WO Line No.", "Line No.");
                            column(WO_Comment_Comments; Comments)
                            {
                            }
                            column(WO_Comment_PM_Work_Order_No_; "PM Work Order No.")
                            {
                            }
                            column(WO_Comment_PM_WO_Line_No_; "PM WO Line No.")
                            {
                            }
                            column(WO_Comment_Line_No_; "Line No.")
                            {
                            }

                            trigger OnPreDataItem()
                            begin
                                if not "Work Order Line"."PMWO Comments" then
                                    CurrReport.Break;
                            end;
                        }
                        dataitem(LineFooter; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                            column(LineFooter_Number; Number)
                            {
                            }

                            trigger OnPreDataItem()
                            begin
                                if not (
                                  "Work Order Line"."PMWO Item Consumption" or
                                  "Work Order Line"."PMWO Resources" or
                                  "Work Order Line"."PMWO Comments")
                                then
                                    CurrReport.Break;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            CalcFields("PMWO Item Consumption", "PMWO Resources", "PMWO Comments");
                            jfdoFormatValue;
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("PM Work Order No.", Table23019260."PM Work Order No.");
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    CurrReport.PageNo := 1;

                    if CopyNo = NoLoops then begin
                        CurrReport.Break;
                    end else
                        CopyNo := CopyNo + 1;
                    if CopyNo = 1 then // Original
                        Clear(CopyTxt)
                    else
                        CopyTxt := Text000;
                end;

                trigger OnPreDataItem()
                begin
                    NoLoops := 1 + Abs(NoCopies);
                    if NoLoops <= 0 then
                        NoLoops := 1;
                    CopyNo := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                gcodActiveVersion := gcduQualityVersionMgt.GetActiveVersion("PM Procedure Code");
                if gcodPrintActiveVersion then
                    if gcodActiveVersion <> "PM Proc. Version No." then
                        CurrReport.Skip;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoCopies; NoCopies)
                    {
                        Caption = 'Number of Copies';
                    }
                    field(gcodPrintActiveVersion; gcodPrintActiveVersion)
                    {
                        Caption = 'Print Active Version Only';
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
        ReportTitle = 'PM Work Order';
        Version = 'Version No. / Active Version';
        PMNo = 'No.';
        PMName = 'Name';
        PMSerialNo = 'Serial No.';
        PMGroupCode = 'PM Group Code';
        PMPersonResp = 'Person Responsible';
        PMWODate = 'Work Order Date';
        PMMaintTime = 'Maintenance Time';
        PMLastWODate = 'Last Work Order Date';
        PMWOFreq = 'Work Order Frequency';
        PMEvalAtQty = 'Evaluated At Qty.';
        PMComments = 'General Comments';
        WOLPMMeasure = 'PM Measure Code';
        WOLDesc = 'Description';
        WOLQualityUOM = 'Quality UOM';
        WOLValueType = 'Value Type';
        WOLDesiredValue = 'Desired Value';
        WOLNotes = 'Notes / Results';
        WOLMin = 'Min';
        WOLMax = 'Max';
        WOLResultValue = 'Result Value';
        WOICInv = 'Inventory Consumed';
        WOICItemNo = 'Item No.';
        WOICDesc = 'Description';
        WOICUOM = 'Unit of Measure';
        WOICQtyInstalled = 'Quantity Installed';
        WOREquip = 'Equipment Required';
        WORType = 'Type';
        WORNo = 'No.';
        WORDesc = 'Description';
        WOLC = 'Work Order Line Comments';
        CompletedBy = 'Completed By';
        Supervisor = 'Supervisor';
    }

    var
        gvarValue: Variant;
        gvarDesiredValue: Variant;
        gcduQualityVersionMgt: Codeunit Codeunit23019250;
        gcodActiveVersion: Code[10];
        gcodPrintActiveVersion: Boolean;
        CopyTxt: Text[10];
        NoCopies: Integer;
        NoLoops: Integer;
        CopyNo: Integer;
        Text000: Label 'COPY';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        PM_Work_OrderCaptionLbl: Label 'PM Work Order';
        Version_No____Active_VersionCaptionLbl: Label 'Version No. / Active Version';
        Work_Order_Header___Work_Order_Freq__CaptionLbl: Label 'Work Order Freq.';
        Work_Order_Header___Last_Work_Order_Date_CaptionLbl: Label 'Last Work Order Date';
        FORMAT__Work_Order_Header___Maintenance_Time____________Work_Order_Header___Maintenance_UOM_CaptionLbl: Label 'Maintenance Time';
        Starting_DateCaptionLbl: Label 'Work Order Date';
        Work_Order_Header___Person_Responsible_CaptionLbl: Label 'Person Responsible';
        Work_Order_Header___PM_Group_Code_CaptionLbl: Label 'PM Group Code';
        Work_Order_Header__NameCaptionLbl: Label 'Name';
        Work_Order_Header___No__CaptionLbl: Label 'No.';
        Work_Order_Header___Serial_No__CaptionLbl: Label 'Serial No.';
        Work_Order_Header___Evaluated_At_Qty__CaptionLbl: Label 'Evaluated At Qty.';
        General_Comments_CaptionLbl: Label 'General Comments:';
        Work_Order_Line__PM_Unit_of_Measure_CaptionLbl: Label 'Quality UOM';
        gvarDesiredValueCaptionLbl: Label 'Desired Value';
        Notes___ResultsCaptionLbl: Label 'Notes / Results';
        MinCaptionLbl: Label 'Min';
        MaxCaptionLbl: Label 'Max';
        Completed_ByCaptionLbl: Label 'Completed By';
        SupervisorCaptionLbl: Label 'Supervisor';
        Inventory_Items_ConsumedCaptionLbl: Label 'Inventory Items Consumed';
        Equipment_RequiredCaptionLbl: Label 'Equipment Required';
        Work_Order_Line_CommentsCaptionLbl: Label 'Work Order Line Comments';

    [Scope('Internal')]
    procedure jfdoFormatValue()
    var
        lrecPurchLineProp: Record Table23019016;
        lrecPMProcLine: Record "PM Procedure Line";
    begin
        with "Work Order Line" do begin
            case "Value Type" of
                "Value Type"::Boolean:
                    gvarValue := Format("Boolean Value");
                "Value Type"::Code:
                    gvarValue := "Code Value";
                "Value Type"::Text:
                    gvarValue := "Text Value";
                "Value Type"::Decimal:
                    gvarValue := "Decimal Value";
                "Value Type"::Date:
                    begin
                        gvarValue := Format("Date Value");
                    end;
            end;

            if lrecPMProcLine.Get("PM Procedure Code", "PM Proc. Version No.", "Line No.") then begin
                if lrecPMProcLine."PM Measure Code" = "PM Measure Code" then begin
                    case "Value Type" of
                        "Value Type"::Boolean:
                            begin
                                gvarDesiredValue := Format(lrecPMProcLine."Boolean Value");
                            end;
                        "Value Type"::Code:
                            gvarDesiredValue := lrecPMProcLine."Code Value";
                        "Value Type"::Text:
                            gvarDesiredValue := lrecPMProcLine."Text Value";
                        "Value Type"::Decimal:
                            gvarDesiredValue := lrecPMProcLine."Decimal Value";
                        "Value Type"::Date:
                            begin
                                gvarDesiredValue := Format(lrecPMProcLine."Date Value");
                            end;
                    end;
                end;
            end else
                gvarDesiredValue := '';

        end;
    end;
}

