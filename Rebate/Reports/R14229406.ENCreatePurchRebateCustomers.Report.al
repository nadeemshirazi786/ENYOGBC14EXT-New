report 14229406 "Create Purch Rbt Customers ELA"
{
    //ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - new processing-only report


    Caption = 'Create Purchase Rebate Customers';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                lrecPurchRebateCust: Record "Purchase Rebate Customer ELA";
            begin

                lrecPurchRebateCust.SetRange("Purchase Rebate Code", grecPurchRebate.Code);
                lrecPurchRebateCust.SetRange("Customer No.", "No.");

                if (
                  (not lrecPurchRebateCust.IsEmpty)
                ) then begin

                    CurrReport.Skip;

                end;

                lrecPurchRebateCust.Init;
                lrecPurchRebateCust.Validate("Purchase Rebate Code", grecPurchRebate.Code);
                lrecPurchRebateCust.Validate("Customer No.", "No.");
                lrecPurchRebateCust.Insert(true);
            end;

            trigger OnPreDataItem()
            begin
                grecPurchRebate.TestField(Code);

                grecPurchRebate.Find;

                grecPurchRebate.TestField("Rebate Type", grecPurchRebate."Rebate Type"::"Sales-Based");
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
                    field("grecPurchRebate.Code"; grecPurchRebate.Code)
                    {
                        ApplicationArea = All;
                        Caption = 'Create Purch. Rebate Customers for';
                        TableRelation = "Purchase Rebate Header ELA" WHERE("Rebate Type" = CONST("Sales-Based"));
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
        grecPurchRebate: Record "Purchase Rebate Header ELA";
}

