page 14228890 "EN Approve Order"
{
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(CreditLimit; CreditLimit)
            {
                Caption = 'Credit Limit';
                Editable = false;
            }
            field("Outstanding[1]"; Outstanding[1])
            {
                Caption = 'Amount Outstanding';
                Editable = false;
            }
            field("Outstanding[2]"; Outstanding[2])
            {
                Caption = 'Amount Past Due';
                Editable = false;
            }
            field(CurrentAmount; CurrentAmount)
            {
                Caption = 'Current Order';
                Editable = false;
            }
            field(CashApplied; CashApplied)
            {
                Caption = 'Cash Applied';
                Editable = false;
            }
            field("Outstanding[1] + CurrentAmount - CashApplied - CreditLimit"; Outstanding[1] + CurrentAmount - CashApplied - CreditLimit)
            {
                BlankNumbers = BlankNegAndZero;
                Caption = 'Amount Over Limit';
                Editable = false;
            }
            field(AuthorizedAmount; AuthorizedAmount)
            {
                Caption = 'Authorized Amount';
            }
            field(UsrID; UsrID)
            {
                Caption = 'User ID';
            }
            field(Password; Password)
            {
                Caption = 'Password';
                ExtendedDatatype = Masked;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OK)
            {
                Caption = 'OK';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SalesSetup: Record "Sales & Receivables Setup";
                    MemberOf: Record "Integer";
                begin
                    Message('Note: Form 50032 Approve Order is incomplete, all orders are approved.');
                    CurrPage.Close;


                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (
          (CloseAction <> ACTION::OK)
        ) then begin
            exit;
        end;



        if UsrID = '' then
            Valid := false
        else
            if not User1.Get(UsrID) then
                Valid := false
            else begin
                User1.TestField("Allow C&C Authorization ELA");
                Valid := User1."Approval Password ELA" = Password;
            end;

        if not Valid then
            Error('The combination of user ID and password entered is invalid.  Try again.');
    end;

    var
        Outstanding: array[2] of Decimal;
        CreditLimit: Decimal;
        CurrentAmount: Decimal;
        AuthorizedAmount: Decimal;
        CashApplied: Decimal;
        User1: Record "User Setup";
        UsrID: Code[20];
        Password: Text[10];
        Valid: Boolean;


    procedure SetVariables(Out: array[2] of Decimal; Lim: Decimal; Current: Decimal; Authorized: Decimal; Applied: Decimal)
    begin
        Outstanding[1] := Out[1];
        Outstanding[2] := Out[2];
        CreditLimit := Lim;
        CurrentAmount := Current;
        AuthorizedAmount := Authorized;
        CashApplied := Applied;
    end;


    procedure GetVariables(var User: Code[20]; var Amt: Decimal): Code[20]
    begin
        User := UserId;
        Amt := AuthorizedAmount;
        exit;

        if Valid then begin
            User := UsrID;
            Amt := AuthorizedAmount;
        end;
    end;
}

