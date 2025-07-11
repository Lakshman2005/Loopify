import { useState, useEffect } from "react";
import { LocalMusicUploader } from "@/components/LocalMusicUploader";
import { TrackCard } from "@/components/TrackCard";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Music, Heart, Clock, Download } from "lucide-react";

interface LocalTrack {
  id: string;
  title: string;
  artist: string;
  duration: number;
  file: File;
  url: string;
  size: number;
}

interface LibraryProps {
  onPlayTrack: (track: any) => void;
  currentTrack?: any;
  isPlaying: boolean;
}

export default function Library({ onPlayTrack, currentTrack, isPlaying }: LibraryProps) {
  const [localTracks, setLocalTracks] = useState<LocalTrack[]>([]);
  const [likedTracks, setLikedTracks] = useState<any[]>([]);
  const [recentlyPlayed, setRecentlyPlayed] = useState<any[]>([]);

  // Load local tracks from localStorage on component mount
  useEffect(() => {
    const saved = localStorage.getItem('loopify-local-tracks');
    if (saved) {
      try {
        const tracks = JSON.parse(saved);
        // Recreate File objects and URLs (these can't be serialized)
        const restoredTracks = tracks.map((track: any) => ({
          ...track,
          // Note: File object and URL will need to be recreated when app restarts
          file: null,
          url: track.url // This might not work after restart
        }));
        setLocalTracks(restoredTracks);
      } catch (error) {
        console.error('Error loading local tracks:', error);
      }
    }
  }, []);

  const handleTracksAdded = (newTracks: LocalTrack[]) => {
    const updatedTracks = [...localTracks, ...newTracks];
    setLocalTracks(updatedTracks);
    
    // Save to localStorage (excluding File objects)
    const tracksToSave = updatedTracks.map(track => ({
      ...track,
      file: null // Remove file object for serialization
    }));
    localStorage.setItem('loopify-local-tracks', JSON.stringify(tracksToSave));
  };

  const handleRemoveTrack = (trackId: string) => {
    const updatedTracks = localTracks.filter(track => track.id !== trackId);
    setLocalTracks(updatedTracks);
    
    // Update localStorage
    const tracksToSave = updatedTracks.map(track => ({
      ...track,
      file: null
    }));
    localStorage.setItem('loopify-local-tracks', JSON.stringify(tracksToSave));
  };

  const handlePlayLocalTrack = (track: LocalTrack) => {
    const formattedTrack = {
      id: track.id,
      title: track.title,
      artist: track.artist,
      album: 'Local Music',
      duration: track.duration,
      cover: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
      url: track.url
    };
    onPlayTrack(formattedTrack);
  };

  const totalLocalDuration = localTracks.reduce((total, track) => total + track.duration, 0);
  const formatTotalTime = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    return hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
  };

  return (
    <div className="space-y-8 pb-32">
      {/* Header */}
      <div className="space-y-4">
        <h1 className="text-3xl font-bold text-foreground">Your Library</h1>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-music-primary/10 rounded-lg flex items-center justify-center">
                <Download className="h-6 w-6 text-music-primary" />
              </div>
              <div>
                <h3 className="font-semibold text-foreground">{localTracks.length}</h3>
                <p className="text-sm text-muted-foreground">Downloaded Songs</p>
              </div>
            </div>
          </Card>
          
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-pink-500/10 rounded-lg flex items-center justify-center">
                <Heart className="h-6 w-6 text-pink-500" />
              </div>
              <div>
                <h3 className="font-semibold text-foreground">{likedTracks.length}</h3>
                <p className="text-sm text-muted-foreground">Liked Songs</p>
              </div>
            </div>
          </Card>
          
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-blue-500/10 rounded-lg flex items-center justify-center">
                <Clock className="h-6 w-6 text-blue-500" />
              </div>
              <div>
                <h3 className="font-semibold text-foreground">{formatTotalTime(totalLocalDuration)}</h3>
                <p className="text-sm text-muted-foreground">Total Playtime</p>
              </div>
            </div>
          </Card>
        </div>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="local" className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="local">Local Music</TabsTrigger>
          <TabsTrigger value="liked">Liked Songs</TabsTrigger>
          <TabsTrigger value="recent">Recently Played</TabsTrigger>
          <TabsTrigger value="playlists">Playlists</TabsTrigger>
        </TabsList>

        <TabsContent value="local" className="space-y-6">
          <LocalMusicUploader
            onTracksAdded={handleTracksAdded}
            localTracks={localTracks}
            onRemoveTrack={handleRemoveTrack}
          />
          
          {localTracks.length > 0 && (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h2 className="text-xl font-semibold text-foreground">Your Music</h2>
                <Button variant="outline" size="sm">
                  Play All
                </Button>
              </div>
              
              <div className="space-y-2">
                {localTracks.map((track, index) => (
                  <TrackCard
                    key={track.id}
                    track={{
                      id: track.id,
                      title: track.title,
                      artist: track.artist,
                      album: 'Local Music',
                      duration: track.duration,
                      cover: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop'
                    }}
                    isPlaying={currentTrack?.id === track.id && isPlaying}
                    onPlay={() => handlePlayLocalTrack(track)}
                    index={index}
                  />
                ))}
              </div>
            </div>
          )}
        </TabsContent>

        <TabsContent value="liked">
          <div className="text-center py-12">
            <Heart className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-foreground mb-2">No liked songs yet</h3>
            <p className="text-muted-foreground">Songs you like will appear here</p>
          </div>
        </TabsContent>

        <TabsContent value="recent">
          <div className="text-center py-12">
            <Clock className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-foreground mb-2">No recent plays</h3>
            <p className="text-muted-foreground">Your recently played tracks will appear here</p>
          </div>
        </TabsContent>

        <TabsContent value="playlists">
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-foreground">Your Playlists</h2>
              <Button className="bg-music-primary hover:bg-music-primary/90">
                Create Playlist
              </Button>
            </div>
            
            <div className="text-center py-12">
              <Music className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-foreground mb-2">No playlists yet</h3>
              <p className="text-muted-foreground">Create your first playlist to get started</p>
            </div>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}