page 14229401 "Create Rebate Adjustment ELA"
{

    // ENRE1.00
    //    - new page


    Caption = 'Create Rebate Adjustment';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    InstructionalText = 'Do you want to post a rebate adjustment?';
    ModifyAllowed = false;
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field(gdecAdjustmentAmount; gdecAdjustmentAmount)
            {
                ApplicationArea = All;
                Caption = 'Adjustment Amount';
            }
            field(gcodReasonCode; gcodReasonCode)
            {
                ApplicationArea = All;
                Caption = 'Reason Code';
                TableRelation = "Reason Code";
            }
        }
    }

    actions
    {
    }

    var
        gdecAdjustmentAmount: Decimal;
        gcodReasonCode: Code[10];


    procedure ReturnPostingInfo(var pdecAdjustmentAmount: Decimal; var pcodReasonCode: Code[10])
    begin
        pdecAdjustmentAmount := gdecAdjustmentAmount;
        pcodReasonCode := gcodReasonCode;
    end;
}

