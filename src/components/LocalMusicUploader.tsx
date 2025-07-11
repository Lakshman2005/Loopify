import { useState, useRef } from "react";
import { Upload, Music, X, FileAudio } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { useToast } from "@/hooks/use-toast";

interface LocalTrack {
  id: string;
  title: string;
  artist: string;
  duration: number;
  file: File;
  url: string;
  size: number;
}

interface LocalMusicUploaderProps {
  onTracksAdded: (tracks: LocalTrack[]) => void;
  localTracks: LocalTrack[];
  onRemoveTrack: (trackId: string) => void;
}

export function LocalMusicUploader({ onTracksAdded, localTracks, onRemoveTrack }: LocalMusicUploaderProps) {
  const [uploading, setUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const { toast } = useToast();

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(event.target.files || []);
    if (files.length === 0) return;

    setUploading(true);
    setUploadProgress(0);

    const audioFiles = files.filter(file => file.type.startsWith('audio/'));
    
    if (audioFiles.length === 0) {
      toast({
        title: "Invalid files",
        description: "Please select audio files only",
        variant: "destructive"
      });
      setUploading(false);
      return;
    }

    const newTracks: LocalTrack[] = [];

    for (let i = 0; i < audioFiles.length; i++) {
      const file = audioFiles[i];
      const url = URL.createObjectURL(file);
      
      try {
        const duration = await getAudioDuration(url);
        const fileName = file.name.replace(/\.[^/.]+$/, "");
        const [title, artist] = fileName.includes(' - ') 
          ? fileName.split(' - ', 2) 
          : [fileName, 'Unknown Artist'];

        const track: LocalTrack = {
          id: `local-${Date.now()}-${i}`,
          title: title.trim(),
          artist: artist.trim(),
          duration,
          file,
          url,
          size: file.size
        };

        newTracks.push(track);
        setUploadProgress(((i + 1) / audioFiles.length) * 100);
      } catch (error) {
        console.error('Error processing file:', error);
        toast({
          title: "Error processing file",
          description: `Could not process ${file.name}`,
          variant: "destructive"
        });
      }
    }

    onTracksAdded(newTracks);
    setUploading(false);
    setUploadProgress(0);
    
    toast({
      title: "Files uploaded successfully",
      description: `Added ${newTracks.length} track(s) to your library`
    });

    // Reset file input
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const getAudioDuration = (url: string): Promise<number> => {
    return new Promise((resolve, reject) => {
      const audio = new Audio();
      audio.addEventListener('loadedmetadata', () => {
        resolve(audio.duration);
      });
      audio.addEventListener('error', reject);
      audio.src = url;
    });
  };

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="space-y-6">
      {/* Upload Area */}
      <Card className="p-6">
        <div className="text-center space-y-4">
          <div className="w-16 h-16 bg-music-primary/10 rounded-full flex items-center justify-center mx-auto">
            <FileAudio className="h-8 w-8 text-music-primary" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-foreground mb-2">
              Upload Your Music
            </h3>
            <p className="text-muted-foreground text-sm">
              Add your local music files to Loopify. Supports MP3, WAV, FLAC, and more.
            </p>
          </div>
          
          <input
            ref={fileInputRef}
            type="file"
            multiple
            accept="audio/*"
            onChange={handleFileSelect}
            className="hidden"
          />
          
          <Button
            onClick={() => fileInputRef.current?.click()}
            disabled={uploading}
            className="bg-music-primary hover:bg-music-primary/90"
          >
            <Upload className="h-4 w-4 mr-2" />
            {uploading ? "Processing..." : "Choose Files"}
          </Button>
          
          {uploading && (
            <div className="space-y-2">
              <Progress value={uploadProgress} className="w-full" />
              <p className="text-sm text-muted-foreground">
                Processing files... {Math.round(uploadProgress)}%
              </p>
            </div>
          )}
        </div>
      </Card>

      {/* Local Tracks List */}
      {localTracks.length > 0 && (
        <Card className="p-4">
          <div className="flex items-center gap-2 mb-4">
            <Music className="h-5 w-5 text-music-primary" />
            <h3 className="text-lg font-semibold text-foreground">
              Local Music ({localTracks.length})
            </h3>
          </div>
          
          <div className="space-y-2">
            {localTracks.map((track) => (
              <div
                key={track.id}
                className="flex items-center gap-3 p-3 rounded-lg hover:bg-accent/50 transition-colors"
              >
                <div className="w-10 h-10 bg-music-primary/10 rounded-lg flex items-center justify-center">
                  <Music className="h-5 w-5 text-music-primary" />
                </div>
                
                <div className="flex-1 min-w-0">
                  <h4 className="font-medium text-foreground truncate">{track.title}</h4>
                  <p className="text-sm text-muted-foreground truncate">{track.artist}</p>
                </div>
                
                <div className="text-right">
                  <p className="text-sm text-muted-foreground">
                    {formatDuration(track.duration)}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {formatFileSize(track.size)}
                  </p>
                </div>
                
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => onRemoveTrack(track.id)}
                  className="h-8 w-8 p-0 hover:bg-destructive/10 hover:text-destructive"
                >
                  <X className="h-4 w-4" />
                </Button>
              </div>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
}