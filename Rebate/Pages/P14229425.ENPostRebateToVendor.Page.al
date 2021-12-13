page 14229425 "Post Rebate To Vendor ELA"
{

    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(DocNo; DocNo)
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                }
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                }
                field(goptAction; goptAction)
                {
                    ApplicationArea = All;
                    Caption = 'Action';
                    OptionCaption = 'Post Only';
                }
            }
        }
    }

    actions
    {
    }

    var
        DocNo: Code[20];
        PostingDate: Date;
        goptAction: Option "Post Only","Post and Create Refund";


    procedure SetValues(NewDocNo: Code[20]; NewPostingDate: Date; goptNewAction: Option)
    begin
        DocNo := NewDocNo;
        PostingDate := NewPostingDate;
        goptAction := goptNewAction;
    end;


    procedure GetValues(var NewDocNo: Code[20]; var NewPostingDate: Date; var goptNewAction: Option)
    begin
        NewDocNo := DocNo;
        NewPostingDate := PostingDate;
        goptNewAction := goptAction;
    end;
}

