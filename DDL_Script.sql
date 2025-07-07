CREATE SCHEMA tender;
SET search_path TO tender;
-- 1. Tender Table
CREATE TABLE Tender (
 TenderID SERIAL PRIMARY KEY,
 T_Name VARCHAR(100),
 Description TEXT,
 Status VARCHAR(20),
 Budget NUMERIC(12, 2),
 Deadline DATE
);
-- 2. Vendor Table
CREATE TABLE Vendor (
 VendorID SERIAL PRIMARY KEY,
 V_Name VARCHAR(100),
 Contact VARCHAR(15),
 CompletedContracts INT DEFAULT 0,
 OngoingContracts INT DEFAULT 0,
 AbandonedContracts INT DEFAULT 0,
 IsRedFlagged BOOLEAN DEFAULT FALSE,
 IsBlocked BOOLEAN DEFAULT FALSE
);
-- 3. AuditCommittee Table
CREATE TABLE AuditCommittee (
 UserID SERIAL PRIMARY KEY,
 Contact VARCHAR(15),
 EmailID VARCHAR(100),
 Role VARCHAR(50),
 Name VARCHAR(100)
);
-- 4. BidEval Table (no manual insert - trigger controlled)
CREATE TABLE BidEval (
 EvalID SERIAL PRIMARY KEY,
 ApprovalDate DATE DEFAULT CURRENT_DATE,
 ApprovalStatus VARCHAR(20),
 FOREIGN KEY (UserID) INT REFERENCES AuditCommittee(UserID)
);
-- 5. Bids Table
CREATE TABLE Bids (
 BidID SERIAL PRIMARY KEY,
 BidAmount NUMERIC(12, 2),
 FOREIGN KEY (TenderID) INT REFERENCES Tender(TenderID),
 FOREIGN KEY (VendorID) INT REFERENCES Vendor(VendorID),
 FOREIGN KEY (EvalID) INT REFERENCES BidEval(EvalID),
 FOREIGN KEY (EvaluatedBy) INT REFERENCES AuditCommittee(UserID)
);
-- 6. Contract Table
CREATE TABLE Contract (
 ContractID SERIAL PRIMARY KEY,
 FOREIGN KEY (TenderID) INT REFERENCES Tender(TenderID),
 FOREIGN KEY (VendorID) INT REFERENCES Vendor(VendorID),
 ContractStatus VARCHAR(30),
 Start_Date DATE,
 End_Date DATE,
 Amount NUMERIC(12, 2)
);
--7. Payments Table (Weak Entity)
CREATE TABLE Payments (
 PaymentID SERIAL,
 ContractID INT,
 AmountPaid NUMERIC(12, 2),
 PaymentDate DATE,
 PRIMARY KEY (PaymentID, ContractID),
 FOREIGN KEY (ContractID) REFERENCES Contract(ContractID)
);
