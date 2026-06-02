/**
 * Video Exporter Engine for Flutter Web Photobooth
 * Composites a session video into a photobooth frame and records the result.
 */

window.exportRecapVideo = async function (videoUrl, frameUrl, layoutDataJson, preferredMimeType, isMirrored) {
    const layoutData = JSON.parse(layoutDataJson);
    const { canvasWidth, canvasHeight, slots, timestamps, recapDuration } = layoutData;
    const durationSec = recapDuration || 2.0;

    return new Promise(async (resolve, reject) => {
        try {
            // 1. Create hidden elements
            const canvas = document.createElement('canvas');
            canvas.width = canvasWidth;
            canvas.height = canvasHeight;
            const ctx = canvas.getContext('2d');

            // 2. Load Frame Image
            const frameImg = new Image();
            frameImg.crossOrigin = "anonymous";
            await new Promise((res, rej) => {
                frameImg.onload = res;
                frameImg.onerror = () => rej(new Error("Failed to load frame image"));
                frameImg.src = frameUrl;
            });

            // 3. Prepare Video Elements for each slot
            const videoElements = await Promise.all(slots.map(async (slot, index) => {
                const v = document.createElement('video');
                v.crossOrigin = "anonymous";
                v.muted = true;
                v.playsInline = true;
                v.setAttribute('playsinline', '');
                v.setAttribute('webkit-playsinline', '');
                v.src = videoUrl;

                await new Promise((res) => { v.onloadedmetadata = res; });

                const photoTime = timestamps && timestamps[index] !== undefined ? timestamps[index] : 0;
                const startTime = Math.max(0, photoTime - durationSec);
                
                v.currentTime = startTime;
                await new Promise((res) => { v.onseeked = res; });
                
                return {
                    element: v,
                    startTime: startTime,
                    endTime: photoTime,
                    isDone: false
                };
            }));

            // 4. Setup MediaRecorder
            const stream = canvas.captureStream(30);
            
            const mimeTypes = [
                'video/mp4;codecs=avc1',
                'video/mp4',
                'video/webm;codecs=vp9,opus',
                'video/webm;codecs=vp8,opus',
                'video/webm'
            ];
            
            let selectedMimeType = '';
            
            // Prioritize preferred mime type if provided and supported
            if (preferredMimeType && MediaRecorder.isTypeSupported(preferredMimeType)) {
                selectedMimeType = preferredMimeType;
            } else {
                for (const type of mimeTypes) {
                    if (MediaRecorder.isTypeSupported(type)) {
                        selectedMimeType = type;
                        break;
                    }
                }
            }

            const recorder = new MediaRecorder(stream, {
                mimeType: selectedMimeType,
                videoBitsPerSecond: 8000000 
            });

            const chunks = [];
            recorder.ondataavailable = (e) => {
                if (e.data.size > 0) chunks.push(e.data);
            };
            
            recorder.onstop = () => {
                const blob = new Blob(chunks, { type: selectedMimeType || 'video/webm' });
                resolve(blob);
            };

            // 5. Rendering & Recording Loop
            const durationLimit = (durationSec + 0.5) * 1000; 
            const startTimeMillis = Date.now();

            const drawFrame = () => {
                const elapsed = Date.now() - startTimeMillis;
                const allDone = videoElements.every(v => v.isDone || v.element.currentTime >= v.endTime);
                
                if (allDone || elapsed > durationLimit) {
                    if (recorder.state === "recording") {
                        recorder.stop();
                    }
                    return;
                }

                ctx.imageSmoothingEnabled = true;
                ctx.imageSmoothingQuality = 'high';
                ctx.clearRect(0, 0, canvasWidth, canvasHeight);

                videoElements.forEach((vObj, index) => {
                    const video = vObj.element;
                    const slot = slots[index];

                    const videoAspect = video.videoWidth / video.videoHeight;
                    const slotAspect = slot.w / slot.h;

                    let sx, sy, sw, sh;
                    if (videoAspect > slotAspect) {
                        sh = video.videoHeight;
                        sw = sh * slotAspect;
                        sx = (video.videoWidth - sw) / 2;
                        sy = 0;
                    } else {
                        sw = video.videoWidth;
                        sh = sw / slotAspect;
                        sx = 0;
                        sy = (video.videoHeight - sh) / 2;
                    }

                    if (isMirrored) {
                        ctx.save();
                        // Di chuyển đến vị trí bên phải của ô, lật ngược trục X
                        ctx.translate(slot.x + slot.w, slot.y);
                        ctx.scale(-1, 1);
                        ctx.drawImage(video, sx, sy, sw, sh, 0, 0, slot.w, slot.h);
                        ctx.restore();
                    } else {
                        ctx.drawImage(video, sx, sy, sw, sh, slot.x, slot.y, slot.w, slot.h);
                    }
                    
                    if (video.currentTime >= vObj.endTime) {
                        vObj.isDone = true;
                        video.pause();
                    }
                });

                ctx.drawImage(frameImg, 0, 0, canvasWidth, canvasHeight);

                if (recorder.state === "recording") {
                    requestAnimationFrame(drawFrame);
                }
            };

            recorder.start();
            await Promise.all(videoElements.map(v => v.element.play()));
            drawFrame();

            setTimeout(() => {
                if (recorder.state === "recording") {
                    recorder.stop();
                }
            }, 60000);

        } catch (error) {
            console.error("Export Error:", error);
            reject(error);
        }
    });
};

window.flipVideo = async function (videoUrl, isMirrored, preferredMimeType) {
    if (!isMirrored) {
        const response = await fetch(videoUrl);
        return await response.blob();
    }

    return new Promise(async (resolve, reject) => {
        try {
            const v = document.createElement('video');
            v.crossOrigin = "anonymous";
            v.muted = true;
            v.playsInline = true;
            v.setAttribute('playsinline', '');
            v.setAttribute('webkit-playsinline', '');
            v.src = videoUrl;
            await new Promise((res) => { v.onloadedmetadata = res; });

            const canvas = document.createElement('canvas');
            canvas.width = v.videoWidth;
            canvas.height = v.videoHeight;
            const ctx = canvas.getContext('2d');

            const stream = canvas.captureStream(30);
            const recorder = new MediaRecorder(stream, {
                mimeType: preferredMimeType || 'video/webm',
                videoBitsPerSecond: 8000000
            });

            const chunks = [];
            recorder.ondataavailable = (e) => {
                if (e.data.size > 0) chunks.push(e.data);
            };

            recorder.onstop = () => {
                const blob = new Blob(chunks, { type: recorder.mimeType });
                resolve(blob);
            };

            const draw = () => {
                if (v.ended || v.paused) {
                    if (recorder.state === "recording") recorder.stop();
                    return;
                }
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.save();
                ctx.translate(canvas.width, 0);
                ctx.scale(-1, 1);
                ctx.drawImage(v, 0, 0, canvas.width, canvas.height);
                ctx.restore();
                
                if (recorder.state === "recording") {
                    requestAnimationFrame(draw);
                }
            };

            recorder.start();
            v.play();
            draw();

            v.onended = () => {
                if (recorder.state === "recording") recorder.stop();
            };

        } catch (e) {
            reject(e);
        }
    });
};

window.saveFilesToDevice = async function (filesMap) {
    let useDirectoryPicker = typeof window.showDirectoryPicker === 'function';
    
    if (useDirectoryPicker) {
        try {
            const dirHandle = await window.showDirectoryPicker({
                mode: 'readwrite'
            });
            
            for (const [fileName, fileData] of Object.entries(filesMap)) {
                const blob = fileData instanceof Blob ? fileData : new Blob([fileData]);
                const fileHandle = await dirHandle.getFileHandle(fileName, { create: true });
                const writable = await fileHandle.createWritable();
                await writable.write(blob);
                await writable.close();
            }
            return "success";
        } catch (e) {
            if (e.name === 'AbortError') {
                return "aborted";
            }
            console.warn("Directory picker failed, falling back to direct download:", e);
        }
    }
    
    // Fallback: download files individually
    for (const [fileName, fileData] of Object.entries(filesMap)) {
        const blob = fileData instanceof Blob ? fileData : new Blob([fileData]);
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        await new Promise(resolve => setTimeout(resolve, 300));
        URL.revokeObjectURL(url);
    }
    return "downloaded";
};
