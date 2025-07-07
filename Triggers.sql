CREATE OR REPLACE FUNCTION handle_redflag_vendor()
RETURNS TRIGGER AS $$
BEGIN
 -- Check if vendor's abandoned contracts have reached or exceeded 2
 IF NEW.AbandonedContracts >= 2 THEN
 -- Only update if the vendor is not already red-flagged or blocked
 IF NOT EXISTS (SELECT 1 FROM Vendor WHERE VendorID = NEW.VendorID
AND IsRedFlagged = TRUE AND IsBlocked = TRUE) THEN
 UPDATE Vendor
 SET IsRedFlagged = TRUE, IsBlocked = TRUE
 WHERE VendorID = NEW.VendorID;
 -- Delete all ongoing bids of the vendor
 DELETE FROM Bids
 WHERE VendorID = NEW.VendorID;
 END IF;
 END IF;
 RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_redflag_check
AFTER INSERT OR UPDATE ON Vendor
FOR EACH ROW
EXECUTE PROCEDURE handle_redflag_vendor();
CREATE TRIGGER trg_redflag_check
AFTER INSERT OR UPDATE ON Vendor
FOR EACH ROW
EXECUTE PROCEDURE handle_redflag_vendor();
-- Trigger 2: Automatically create a BidEval entry based on vendor status
CREATE OR REPLACE FUNCTION auto_evaluate_bid()
RETURNS TRIGGER AS $$
DECLARE
 is_blocked BOOLEAN;
 audit_user INT;
 new_eval_id INT;
 approval TEXT;
BEGIN
 SELECT IsBlocked INTO is_blocked
 FROM Vendor
 WHERE VendorID = NEW.VendorID;
 SELECT UserID INTO audit_user
 FROM AuditCommittee
 ORDER BY RANDOM()
 LIMIT 1;
 IF is_blocked THEN
 approval := 'Rejected';
 ELSE
 approval := 'Approved';
 END IF;
 INSERT INTO BidEval (ApprovalStatus, UserID)
 VALUES (approval, audit_user)
 RETURNING EvalID INTO new_eval_id;
 NEW.EvalID := new_eval_id;
 NEW.EvaluatedBy := audit_user;
 RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_auto_eval_bid
BEFORE INSERT ON Bids
FOR EACH ROW
EXECUTE PROCEDURE auto_evaluate_bid();
