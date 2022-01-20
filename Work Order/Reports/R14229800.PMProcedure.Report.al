report 14229800 "PM Procedure ELA"
{
    DefaultLayout = RDLC;
    RDLCLayout = './PMProcedure.rdlc';


    dataset
    {
        dataitem("PM Procedure Header"; "PM Procedure Header")
        {
            RequestFilterFields = "Code", "Version No.", Status, "Person Responsible", "Starting Date";
            column(PM_Procedure_Header_Code; Code)
            {
            }
            column(PM_Procedure_Header_Version_No_; "Version No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING (Number);
                column(gcodSubItem; gcodSubItem)
                {
                }
                column(CopyNo; CopyNo)
                {
                }
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));
                    column(USERID; UserId)
                    {
                    }
                    column(CurrReport_PAGENO; CurrReport.PageNo)
                    {
                    }
                    column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
                    {
                    }
                    column(COMPANYNAME; CompanyName)
                    {
                    }
                    column(CopyTxt; CopyTxt)
                    {
                    }
                    column(PM_Procedure_Header__Description; "PM Procedure Header".Description)
                    {
                    }
                    column(PM_Procedure_Header___Version_No___________gcodActiveVersion; "PM Procedure Header"."Version No." + '/' + gcodActiveVersion)
                    {
                    }
                    column(PM_Procedure_Header__Code; "PM Procedure Header".Code)
                    {
                    }
                    column(PM_Procedure_Header__Status; "PM Procedure Header".Status)
                    {
                    }
                    column(PM_Procedure_Header___Person_Responsible_; "PM Procedure Header"."Person Responsible")
                    {
                    }
                    column(PM_Procedure_Header___Work_Order_Freq__; "PM Procedure Header"."Work Order Freq.")
                    {
                    }
                    column(PM_Procedure_Header___Last_Work_Order_Date_; "PM Procedure Header"."Last Work Order Date")
                    {
                    }
                    column(Starting_Date; "PM Procedure Header"."Starting Date")
                    {
                    }
                    column(FORMAT__PM_Procedure_Header___Maintenance_Time____________PM_Procedure_Header___Maintenance_UOM_; Format("PM Procedure Header"."Maintenance Time") + ' ' + "PM Procedure Header"."Maintenance UOM")
                    {
                    }
                    column(PM_Procedure_Header___PM_Group_Code_; "PM Procedure Header"."PM Group Code")
                    {
                    }
                    column(PM_Procedure_Header__Name; "PM Procedure Header".Name)
                    {
                    }
                    column(PM_Procedure_Header___No__; "PM Procedure Header"."No.")
                    {
                    }
                    column(PM_Procedure_Header___Serial_No__; "PM Procedure Header"."Serial No.")
                    {
                    }
                    column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
                    {
                    }
                    column(PM_ProcedureCaption; PM_ProcedureCaptionLbl)
                    {
                    }
                    column(Version_No____Active_VersionCaption; Version_No____Active_VersionCaptionLbl)
                    {
                    }
                    column(StatusCaption; StatusCaptionLbl)
                    {
                    }
                    column(PM_Procedure_Header___Work_Order_Freq__Caption; PM_Procedure_Header___Work_Order_Freq__CaptionLbl)
                    {
                    }
                    column(PM_Procedure_Header___Last_Work_Order_Date_Caption; PM_Procedure_Header___Last_Work_Order_Date_CaptionLbl)
                    {
                    }
                    column(PM_Procedure_Header___Person_Responsible_Caption; PM_Procedure_Header___Person_Responsible_CaptionLbl)
                    {
                    }
                    column(FORMAT__PM_Procedure_Header___Maintenance_Time____________PM_Procedure_Header___Maintenance_UOM_Caption; FORMAT__PM_Procedure_Header___Maintenance_Time____________PM_Procedure_Header___Maintenance_UOM_CaptionLbl)
                    {
                    }
                    column(Starting_DateCaption; "PM Procedure Header".FieldCaption("Starting Date"))
                    {
                    }
                    column(PM_Procedure_Header___PM_Group_Code_Caption; PM_Procedure_Header___PM_Group_Code_CaptionLbl)
                    {
                    }
                    column(PM_Procedure_Header__NameCaption; PM_Procedure_Header__NameCaptionLbl)
                    {
                    }
                    column(PM_Procedure_Header___No__Caption; PM_Procedure_Header___No__CaptionLbl)
                    {
                    }
                    column(PM_Procedure_Header___Serial_No__Caption; PM_Procedure_Header___Serial_No__CaptionLbl)
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        gcodSubItem := '1_PAGELOOP';  //<JF32428BB>
                    end;
                }
                dataitem(PMWOCommentsGeneral; "PM Proc. Comment")
                {
                    DataItemTableView = SORTING ("PM Procedure Code", "Version No.", "PM Procedure Line No.", "Line No.") WHERE ("PM Procedure Line No." = CONST (0));
                    column(PMWOCommentsGeneral_Comments; Comments)
                    {
                    }
                    column(General_Comments_Caption; General_Comments_CaptionLbl)
                    {
                    }
                    column(PMWOCommentsGeneral_PM_Procedure_Code; "PM Procedure Code")
                    {
                    }
                    column(PMWOCommentsGeneral_Version_No_; "Version No.")
                    {
                    }
                    column(PMWOCommentsGeneral_PM_Procedure_Line_No_; "PM Procedure Line No.")
                    {
                    }
                    column(PMWOCommentsGeneral_Line_No_; "Line No.")
                    {
                    }
                    column(gintCommentRowNumber; gintCommentRowNumber)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        gintCommentRowNumber += 1; //<JF32428BB>
                    end;

                    trigger OnPreDataItem()
                    begin
                        //<JF32428BB>
                        gintCommentRowNumber := 0;
                        gcodSubItem := '2_PMWOCOMMENTSGENERAL';
                        //</JF32428BB>
                        SetRange("PM Procedure Code", "PM Procedure Header".Code);
                        SetRange("Version No.", "PM Procedure Header"."Version No.");
                    end;
                }
                dataitem("PM Procedure Line"; "PM Procedure Line")
                {
                    DataItemTableView = SORTING ("PM Procedure Code", "Version No.", "Line No.");
                    column(PM_Procedure_Line__PM_Measure_Code_; "PM Measure Code")
                    {
                    }
                    column(PM_Procedure_Line__PM_Unit_of_Measure_; "PM Unit of Measure")
                    {
                    }
                    column(PM_Procedure_Line__Value_Type_; "Value Type")
                    {
                    }
                    column(PM_Procedure_Line__Qualification_Code_; "Qualification Code")
                    {
                    }
                    column(PM_Procedure_Line__Employee_No__; "Employee No.")
                    {
                    }
                    column(PM_Procedure_Line__PM_Measure_Cost_; "PM Measure Cost")
                    {
                    }
                    column(gvarValue; gvarValue)
                    {
                    }
                    column(PM_Procedure_Line_Description; Description)
                    {
                    }
                    column(PM_Procedure_Line__Decimal_Min_; "Decimal Min")
                    {
                    }
                    column(PM_Procedure_Line__Decimal_Max_; "Decimal Max")
                    {
                    }
                    column(PM_Procedure_Line__PM_Measure_Code_Caption; FieldCaption("PM Measure Code"))
                    {
                    }
                    column(PM_Procedure_Line__PM_Unit_of_Measure_Caption; PM_Procedure_Line__PM_Unit_of_Measure_CaptionLbl)
                    {
                    }
                    column(PM_Procedure_Line__Value_Type_Caption; FieldCaption("Value Type"))
                    {
                    }
                    column(PM_Procedure_Line__Qualification_Code_Caption; FieldCaption("Qualification Code"))
                    {
                    }
                    column(PM_Procedure_Line__Employee_No__Caption; FieldCaption("Employee No."))
                    {
                    }
                    column(PM_Procedure_Line__PM_Measure_Cost_Caption; FieldCaption("PM Measure Cost"))
                    {
                    }
                    column(gvarValueCaption; gvarValueCaptionLbl)
                    {
                    }
                    column(PM_Procedure_Line_DescriptionCaption; FieldCaption(Description))
                    {
                    }
                    column(MinCaption; MinCaptionLbl)
                    {
                    }
                    column(MaxCaption; MaxCaptionLbl)
                    {
                    }
                    column(Completed_ByCaption; Completed_ByCaptionLbl)
                    {
                    }
                    column(SupervisorCaption; SupervisorCaptionLbl)
                    {
                    }
                    column(PM_Procedure_Line_PM_Procedure_Code; "PM Procedure Code")
                    {
                    }
                    column(PM_Procedure_Line_Version_No_; "Version No.")
                    {
                    }
                    column(PM_Procedure_Line_Line_No_; "Line No.")
                    {
                    }
                    column(gcodSubItemDetail; gcodSubItemDetail)
                    {
                    }
                    column(gintProcedureLineRowNumber; gintProcedureLineRowNumber)
                    {
                    }
                    dataitem(LineHeader; "Integer")
                    {
                        DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));
                        column(LineHeader_Number; Number)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            gcodSubItemDetail := '1_LINEHEADER'; //<JF32428BB>
                            if not ("PM Procedure Line"."PM Item Consumption" or "PM Procedure Line"."PM Resources" or "PM Procedure Line"."PM Comments")
                            then
                                CurrReport.Break;
                        end;
                    }
                    dataitem("PM Item Consumption"; "PM Item Consumption")
                    {
                        DataItemLink = "PM Procedure Code" = FIELD ("PM Procedure Code"), "Version No." = FIELD ("Version No."), "PM Procedure Line No." = FIELD ("Line No.");
                        DataItemTableView = SORTING ("PM Procedure Code", "Version No.", "PM Procedure Line No.", "Line No.");
                        column(PM_Item_Consumption__Item_No__; "Item No.")
                        {
                        }
                        column(PM_Item_Consumption__Unit_of_Measure_; "Unit of Measure")
                        {
                        }
                        column(PM_Item_Consumption__Quantity_Installed_; "Quantity Installed")
                        {
                        }
                        column(PM_Item_Consumption_Description; Description)
                        {
                        }
                        column(PM_Item_Consumption__Quantity_Installed_Caption; FieldCaption("Quantity Installed"))
                        {
                        }
                        column(PM_Item_Consumption__Unit_of_Measure_Caption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(PM_Item_Consumption__Item_No__Caption; FieldCaption("Item No."))
                        {
                        }
                        column(Inventory_Items_ConsumedCaption; Inventory_Items_ConsumedCaptionLbl)
                        {
                        }
                        column(PM_Item_Consumption_DescriptionCaption; FieldCaption(Description))
                        {
                        }
                        column(PM_Item_Consumption_PM_Procedure_Code; "PM Procedure Code")
                        {
                        }
                        column(PM_Item_Consumption_Version_No_; "Version No.")
                        {
                        }
                        column(PM_Item_Consumption_PM_Procedure_Line_No_; "PM Procedure Line No.")
                        {
                        }
                        column(PM_Item_Consumption_Line_No_; "Line No.")
                        {
                        }
                        column(gintItemConsumptionRowNumber; gintItemConsumptionRowNumber)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            gintItemConsumptionRowNumber += 1;  //<JF32428BB>
                        end;

                        trigger OnPreDataItem()
                        begin
                            //<JF32428BB>
                            gintItemConsumptionRowNumber := 0;
                            gcodSubItemDetail := '2_PMITEMCONSUMPTION';
                            //</JF32428BB>
                            if not "PM Procedure Line"."PM Item Consumption" then
                                CurrReport.Break;
                        end;
                    }
                    dataitem("PM Resource"; "PM Resource")
                    {
                        DataItemLink = "PM Procedure Code" = FIELD ("PM Procedure Code"), "Version No." = FIELD ("Version No."), "PM Procedure Line No." = FIELD ("Line No.");
                        DataItemTableView = SORTING ("PM Procedure Code", "Version No.", "PM Procedure Line No.", "Line No.");
                        column(PM_Resource_Description; Description)
                        {
                        }
                        column(PM_Resource__No__; "No.")
                        {
                        }
                        column(PM_Resource_Type; Type)
                        {
                        }
                        column(PM_Resource_DescriptionCaption; FieldCaption(Description))
                        {
                        }
                        column(PM_Resource__No__Caption; FieldCaption("No."))
                        {
                        }
                        column(PM_Resource_TypeCaption; FieldCaption(Type))
                        {
                        }
                        column(Equipment_RequiredCaption; Equipment_RequiredCaptionLbl)
                        {
                        }
                        column(PM_Resource_PM_Procedure_Code; "PM Procedure Code")
                        {
                        }
                        column(PM_Resource_Version_No_; "Version No.")
                        {
                        }
                        column(PM_Resource_PM_Procedure_Line_No_; "PM Procedure Line No.")
                        {
                        }
                        column(PM_Resource_Line_No_; "Line No.")
                        {
                        }
                        column(gintResourceRowNumber; gintResourceRowNumber)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            gintResourceRowNumber += 1; //<JF32428BB>
                        end;

                        trigger OnPreDataItem()
                        begin
                            //<JF32428BB>
                            gintResourceRowNumber := 0;
                            gcodSubItemDetail := '3_PMRESOURCE';
                            //</JF32428BB>
                            if not "PM Procedure Line"."PM Resources" then
                                CurrReport.Break;
                        end;
                    }
                    dataitem("PM Proc. Comment"; "PM Proc. Comment")
                    {
                        DataItemLink = "PM Procedure Code" = FIELD ("PM Procedure Code"), "Version No." = FIELD ("Version No."), "PM Procedure Line No." = FIELD ("Line No.");
                        DataItemTableView = SORTING ("PM Procedure Code", "Version No.", "PM Procedure Line No.", "Line No.");
                        column(PM_Proc__Comment_Comments; Comments)
                        {
                        }
                        column(Procedure_Line_CommentsCaption; Procedure_Line_CommentsCaptionLbl)
                        {
                        }
                        column(PM_Proc__Comment_PM_Procedure_Code; "PM Procedure Code")
                        {
                        }
                        column(PM_Proc__Comment_Version_No_; "Version No.")
                        {
                        }
                        column(PM_Proc__Comment_PM_Procedure_Line_No_; "PM Procedure Line No.")
                        {
                        }
                        column(PM_Proc__Comment_Line_No_; "Line No.")
                        {
                        }
                        column(gintProcCommentRowNumber; gintProcCommentRowNumber)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            gintProcCommentRowNumber += 1;  //<JF32428BB>
                        end;

                        trigger OnPreDataItem()
                        begin
                            //<JF32428BB>
                            gintProcCommentRowNumber := 0;
                            gcodSubItemDetail := '4_PMPROCCOMMENT';
                            //</JF32428BB>
                            if not "PM Procedure Line"."PM Comments" then
                                CurrReport.Break;
                        end;
                    }
                    dataitem(LineFooter; "Integer")
                    {
                        DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));
                        column(LineFooter_Number; Number)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            //<JF32428BB>
                            gcodSubItemDetail := '5_LINEFOOTER';
                            //</JF32428BB>
                            if not ("PM Procedure Line"."PM Item Consumption" or "PM Procedure Line"."PM Resources" or "PM Procedure Line"."PM Comments")
                            then
                                CurrReport.Break;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        //<JF32428BB>
                        gintProcedureLineRowNumber += 1;
                        //</JF32428BB>
                        CalcFields("PM Item Consumption", "PM Resources", "PM Comments");
                        jfdoFormatValue;
                    end;

                    trigger OnPreDataItem()
                    begin
                        //<JF32428BB>
                        gintProcedureLineRowNumber := 0;
                        gcodSubItem := '3_PMPROCEDURELINE';
                        //</JF32428BB>
                        SetRange("PM Procedure Code", "PM Procedure Header".Code);
                        SetRange("Version No.", "PM Procedure Header"."Version No.");
                    end;
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
                gcodActiveVersion := gcduQualityVersionMgt.GetActiveVersion(Code);
                if gcodPrintActiveVersion then
                    if gcodActiveVersion <> "Version No." then
                        CurrReport.Skip;

                CopyNo := 0;
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
    }

    var
        gvarValue: Variant;
        gcduQualityVersionMgt: Codeunit Codeunit23019250;
        gcodActiveVersion: Code[10];
        gcodPrintActiveVersion: Boolean;
        CopyTxt: Text[10];
        NoCopies: Integer;
        NoLoops: Integer;
        CopyNo: Integer;
        Text000: Label 'COPY';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        PM_ProcedureCaptionLbl: Label 'PM Procedure';
        Version_No____Active_VersionCaptionLbl: Label 'Version No. / Active Version';
        StatusCaptionLbl: Label 'Status';
        PM_Procedure_Header___Work_Order_Freq__CaptionLbl: Label 'Work Order Freq.';
        PM_Procedure_Header___Last_Work_Order_Date_CaptionLbl: Label 'Last Work Order Date';
        PM_Procedure_Header___Person_Responsible_CaptionLbl: Label 'Person Responsible';
        FORMAT__PM_Procedure_Header___Maintenance_Time____________PM_Procedure_Header___Maintenance_UOM_CaptionLbl: Label 'Maintenance Time';
        PM_Procedure_Header___PM_Group_Code_CaptionLbl: Label 'PM Group Code';
        PM_Procedure_Header__NameCaptionLbl: Label 'Name';
        PM_Procedure_Header___No__CaptionLbl: Label 'No.';
        PM_Procedure_Header___Serial_No__CaptionLbl: Label 'Serial No.';
        General_Comments_CaptionLbl: Label 'General Comments:';
        PM_Procedure_Line__PM_Unit_of_Measure_CaptionLbl: Label 'Quality UOM';
        gvarValueCaptionLbl: Label 'Desired Value';
        MinCaptionLbl: Label 'Min';
        MaxCaptionLbl: Label 'Max';
        Completed_ByCaptionLbl: Label 'Completed By';
        SupervisorCaptionLbl: Label 'Supervisor';
        Inventory_Items_ConsumedCaptionLbl: Label 'Inventory Items Consumed';
        Equipment_RequiredCaptionLbl: Label 'Equipment Required';
        Procedure_Line_CommentsCaptionLbl: Label 'Procedure Line Comments';
        gcodSubItem: Code[30];
        gcodSubItemDetail: Code[30];
        gintCommentRowNumber: Integer;
        gintProcedureLineRowNumber: Integer;
        gintItemConsumptionRowNumber: Integer;
        gintResourceRowNumber: Integer;
        gintProcCommentRowNumber: Integer;

    [Scope('Internal')]
    procedure jfdoFormatValue()
    var
        lrecPurchLineProp: Record Table23019016;
    begin
        with "PM Procedure Line" do begin
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
        end;
    end;
}

