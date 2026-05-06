-- CreateTable
CREATE TABLE "MissionTimeRule" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "groupId" TEXT,
    "title" TEXT NOT NULL,
    "startMinute" INTEGER NOT NULL,
    "endMinute" INTEGER NOT NULL,
    "targetMinutes" INTEGER NOT NULL DEFAULT 60,
    "reminderEnabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MissionTimeRule_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "MissionTimeRule_userId_idx" ON "MissionTimeRule"("userId");

-- CreateIndex
CREATE INDEX "MissionTimeRule_groupId_idx" ON "MissionTimeRule"("groupId");

-- AddForeignKey
ALTER TABLE "MissionTimeRule" ADD CONSTRAINT "MissionTimeRule_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MissionTimeRule" ADD CONSTRAINT "MissionTimeRule_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "MissionGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;
