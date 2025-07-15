package com.example.loopify

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.provider.MediaStore
import android.database.Cursor
import android.os.Build
import android.net.Uri
import android.content.ContentResolver
import android.content.ContentUris
import android.media.MediaScannerConnection
import android.media.MediaMetadataRetriever
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import android.Manifest
import android.content.pm.PackageManager
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "device_music_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidVersion" -> {
                    try {
                        val sdkVersion = android.os.Build.VERSION.SDK_INT
                        result.success(mapOf("sdkVersion" to sdkVersion))
                    } catch (e: Exception) {
                        result.error("ANDROID_VERSION_ERROR", "Failed to get Android version", e.message)
                    }
                }
                "scanMediaStore" -> {
                    try {
                        val musicFiles = scanMediaStoreForMusic()
                        result.success(musicFiles)
                    } catch (e: Exception) {
                        result.error("SCAN_ERROR", "Failed to scan media store", e.message)
                    }
                }
                "extractAlbumArt" -> {
                    try {
                        val filePath = call.argument<String>("filePath") ?: ""
                        val albumArtPath = extractAlbumArtFromFile(filePath)
                        result.success(mapOf("albumArtPath" to albumArtPath))
                    } catch (e: Exception) {
                        result.error("EXTRACT_ERROR", "Failed to extract album art", e.message)
                    }
                }
                "refreshMediaStore" -> {
                    try {
                        refreshMediaStore()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("REFRESH_ERROR", "Failed to refresh media store", e.message)
                    }
                }
                "getAudioFileDuration" -> {
                    try {
                        val filePath = call.argument<String>("filePath") ?: ""
                        val duration = getAudioFileDuration(filePath)
                        result.success(duration)
                    } catch (e: Exception) {
                        result.error("DURATION_ERROR", "Failed to get audio file duration", e.message)
                    }
                }
                "hasPermission" -> {
                    try {
                        val hasPermission = checkMusicPermission()
                        result.success(hasPermission)
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", "Failed to check permission", e.message)
                    }
                }
                "requestPermission" -> {
                    try {
                        requestMusicPermission()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", "Failed to request permission", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun scanMediaStoreForMusic(): List<Map<String, Any>> {
        Log.d("MainActivity", "Starting MediaStore scan for music files...")
        val musicFiles = mutableListOf<Map<String, Any>>()
        val contentResolver: ContentResolver = context.contentResolver
        
        val uri: Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.ALBUM_ID
        )
        
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"
        
        contentResolver.query(uri, projection, selection, null, sortOrder)?.use { cursor ->
            Log.d("MainActivity", "MediaStore query returned ${cursor.count} music files")
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val albumIdColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            
            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val title = cursor.getString(titleColumn) ?: "Unknown Title"
                val artist = cursor.getString(artistColumn) ?: "Unknown Artist"
                val album = cursor.getString(albumColumn) ?: "Unknown Album"
                val path = cursor.getString(dataColumn) ?: ""
                val duration = cursor.getLong(durationColumn)
                val size = cursor.getLong(sizeColumn)
                val albumId = cursor.getLong(albumIdColumn)
                
                // Get album art URI
                val albumArtUri = getAlbumArtUri(albumId)
                
                val musicFile = mapOf(
                    "id" to id.toString(),
                    "title" to title,
                    "artist" to artist,
                    "album" to album,
                    "path" to path,
                    "duration" to duration,
                    "size" to size,
                    "albumArt" to albumArtUri
                )
                
                musicFiles.add(musicFile)
            }
        }
        
        Log.d("MainActivity", "MediaStore scan completed, found ${musicFiles.size} music files")
        return musicFiles
    }
    
    private fun getAlbumArtUri(albumId: Long): String {
        return try {
            val sArtworkUri = Uri.parse("content://media/external/audio/albumart")
            val albumArtUri = ContentUris.withAppendedId(sArtworkUri, albumId)
            albumArtUri.toString()
        } catch (e: Exception) {
            ""
        }
    }
    
    private fun refreshMediaStore() {
        // Trigger media scan for the entire external storage
        val externalStorageDir = context.getExternalFilesDir(null)
        if (externalStorageDir != null) {
            MediaScannerConnection.scanFile(
                context,
                arrayOf(externalStorageDir.absolutePath),
                null,
                null
            )
        }
    }

    private fun extractAlbumArtFromFile(filePath: String): String {
        return try {
            Log.d("MainActivity", "Extracting album art from: $filePath")
            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(filePath)
            
            // Try to get embedded album art
            val albumArt = retriever.embeddedPicture
            if (albumArt != null) {
                Log.d("MainActivity", "Found embedded album art, size: ${albumArt.size} bytes")
                // Save the embedded album art to a temporary file
                val bitmap = BitmapFactory.decodeByteArray(albumArt, 0, albumArt.size)
                if (bitmap != null) {
                    val tempFile = createTempFile("album_art_${System.currentTimeMillis()}", ".jpg")
                    val outputStream = FileOutputStream(tempFile)
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 90, outputStream)
                    outputStream.close()
                    retriever.release()
                    Log.d("MainActivity", "Album art saved to: ${tempFile.absolutePath}")
                    return tempFile.absolutePath
                } else {
                    Log.d("MainActivity", "Failed to decode album art bitmap")
                }
            } else {
                Log.d("MainActivity", "No embedded album art found")
            }
            
            retriever.release()
            return ""
        } catch (e: Exception) {
            Log.e("MainActivity", "Error extracting album art: ${e.message}")
            e.printStackTrace()
            return ""
        }
    }

    private fun getAudioFileDuration(filePath: String): Int {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(filePath)
            val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            durationStr?.toIntOrNull() ?: 0
        } catch (e: Exception) {
            Log.e("MainActivity", "Error getting duration for $filePath: ${e.message}")
            0
        } finally {
            retriever.release()
        }
    }

    private fun checkMusicPermission(): Boolean {
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ (API 33+)
            checkSelfPermission(Manifest.permission.READ_MEDIA_AUDIO) == PackageManager.PERMISSION_GRANTED
        } else {
            // Android 12 and below
            checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
        Log.d("MainActivity", "Music permission check result: $hasPermission")
        return hasPermission
    }

    private fun requestMusicPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ (API 33+)
            requestPermissions(arrayOf(Manifest.permission.READ_MEDIA_AUDIO), 1001)
        } else {
            // Android 12 and below
            requestPermissions(arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE), 1001)
        }
    }

    private fun createTempFile(prefix: String, suffix: String): File {
        val cacheDir = context.cacheDir
        return File.createTempFile(prefix, suffix, cacheDir)
    }
}
