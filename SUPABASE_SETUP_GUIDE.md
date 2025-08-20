# Supabase Storage Setup Guide

## 🚨 Error Fix: "must be owner of table objects"

This error occurs because you don't have admin permissions to modify storage policies via SQL. Follow these steps instead:

## 📋 Step-by-Step Setup

### 1. Create Storage Bucket (Supabase Dashboard)

1. Go to your **Supabase Dashboard**
2. Navigate to **Storage** in the left sidebar
3. Click **"Create Bucket"**
4. Enter details:
   - **Name**: `chat-media`
   - **Public**: ✅ **Checked** (This is important!)
5. Click **"Create Bucket"**

### 2. Set Up Storage Policies

1. In **Storage**, click on your `chat-media` bucket
2. Go to **"Policies"** tab
3. Click **"Add Policy"** and create these 4 policies:

#### Policy 1: Allow Upload
- **Policy Name**: `Allow authenticated users to upload`
- **Allowed Operation**: `INSERT`
- **Target Roles**: `authenticated`
- **USING Expression**: `true`
- **WITH CHECK Expression**: `true`

#### Policy 2: Allow Public Read
- **Policy Name**: `Allow public read access`
- **Allowed Operation**: `SELECT`
- **Target Roles**: `public`
- **USING Expression**: `true`

#### Policy 3: Allow Update Own Files
- **Policy Name**: `Allow users to update their own files`
- **Allowed Operation**: `UPDATE`
- **Target Roles**: `authenticated`
- **USING Expression**: `auth.uid()::text = (storage.foldername(name))[1]`

#### Policy 4: Allow Delete Own Files
- **Policy Name**: `Allow users to delete their own files`
- **Allowed Operation**: `DELETE`
- **Target Roles**: `authenticated`
- **USING Expression**: `auth.uid()::text = (storage.foldername(name))[1]`

## ✅ Verification

After setup, the app will:
- ✅ Automatically check if the bucket exists
- ✅ Show helpful error messages if not configured
- ✅ Upload compressed media files
- ✅ Display media in chat messages

## 🔧 Alternative: Quick SQL Setup (Admin Only)

If you have admin access to your Supabase project, you can run this SQL in the SQL Editor:

```sql
INSERT INTO storage.buckets (id, name, public) 
VALUES ('chat-media', 'chat-media', true)
ON CONFLICT (id) DO NOTHING;
```

Then still set up the policies manually in the Dashboard as described above.

## 🚀 Ready to Test!

Once the bucket and policies are set up:
1. Open the app
2. Go to any discussion chat
3. Tap the blue camera button
4. Select photos/videos
5. Watch them upload with 60% compression! 📸✨

