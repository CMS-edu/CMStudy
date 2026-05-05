CREATE TABLE "MissionGroup" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "inviteCode" TEXT NOT NULL,
    "weeklyTargetMinutes" INTEGER NOT NULL DEFAULT 600,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MissionGroup_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "MissionGroupMember" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'member',
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MissionGroupMember_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "MissionGroup_inviteCode_key" ON "MissionGroup"("inviteCode");
CREATE INDEX "MissionGroup_ownerId_idx" ON "MissionGroup"("ownerId");
CREATE UNIQUE INDEX "MissionGroupMember_groupId_userId_key" ON "MissionGroupMember"("groupId", "userId");
CREATE INDEX "MissionGroupMember_userId_idx" ON "MissionGroupMember"("userId");

ALTER TABLE "MissionGroup"
ADD CONSTRAINT "MissionGroup_ownerId_fkey"
FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "MissionGroupMember"
ADD CONSTRAINT "MissionGroupMember_groupId_fkey"
FOREIGN KEY ("groupId") REFERENCES "MissionGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "MissionGroupMember"
ADD CONSTRAINT "MissionGroupMember_userId_fkey"
FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
